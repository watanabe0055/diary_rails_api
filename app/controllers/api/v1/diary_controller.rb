module Api
  module V1
    class DiaryController < ApplicationController

      #日記一覧API
      def index
          if current_api_v1_user
            user = current_api_v1_user.id
            allDairy = Diary.joins(:user).select('id','user_id','emotion_id','diary_hashtag_id','title','content').where(user_id: user,is_deleted: false).order(created_at: "desc")
            if allDairy.length > 1
              render status: 200, json: { diary: allDairy}
            else
              render json: { status: 'Failure Get Diary Data', message: "日記が存在しません" }
            end
          else
            render json: { status: 'Not Loggend in', message: "ログインしてください" }
          end
      end
      
      #日記詳細API
      def show
        #存在しないレコードの時に、nilを返したい為「find_by」を使ってる
        diary = Diary.find_by(id: params[:id])

        if current_api_v1_user
          if diary == nil
            render status: 400, json: { status: 'not_exist_diary_data', message: '存在しないレコードです' }
          #diaryとuserでidの型が違うから、to_sで合わせてます
          elsif diary.is_deleted == false && diary.user_id == current_api_v1_user.id.to_s
            render status: 200, json: { diary: diary}
          elsif diary.is_deleted == true
            render status: 400, json: { status: 'deleted_diary_data', message: '削除済みのデータです' }
          elsif diary.user_id != current_api_v1_user.id.to_s
            render status: 400, json: { status: 'browsing_authority_diary_data', message: '権限のないデータです' }
          else
            render status: 400, json: { status: 'Erroy', message: '例外処理' }
          end
        else
          render json: { status: 'Not Loggend in', message: "ログインしてください" }
        end
      end

      #日記編集API
      def update
        updateDiary = Diary.find_by(id: params[:id])
        if current_api_v1_user
          if updateDiary == nil
            render status: 400, json: { status: 'not_exist_diary_data', message: '存在しないレコードです' }
          elsif updateDiary.update(post_edit_diary_params) && (updateDiary.is_deleted == false && updateDiary.user_id == current_api_v1_user.id.to_s)
            render status: 200, json: { status: 'SUCCESS', message: 'Updated the post', updateDiary: updateDiary }
          elsif updateDiary.is_deleted == true
            render status: 400, json: { status: 'deleted_diary_data', message: '削除済みのデータです' }
          elsif updateDiary.user_id != current_api_v1_user.id.to_s
            render status: 400, json: { status: 'browsing_authority_diary_data', message: '権限のないデータです' }
          else
            render status: 400, json: { status: 'Erroy', message: '例外処理' }
          end
        else
          render json: { status: 'Not Loggend in', message: "ログインしてください" }
        end
      end

      def destroy
        deleteDiary = Diary.find_by(id: params[:id])
        if current_api_v1_user
          if deleteDiary == nil
            render status: 400, json: { status: 'not_exist_diary_data', message: '存在しないレコードです' }
          elsif deleteDiary.is_deleted == true
            render status: 400, json: { status: 'deleted_diary_data', message: '削除済みのデータです' }
          elsif deleteDiary.user_id != current_api_v1_user.id.to_s
            render status: 400, json: { status: 'browsing_authority_diary_data', message: '権限のないデータです' }
          elsif deleteDiary.update(is_deleted: 1)
            render status: 200, json: { status: 'SUCCESS', message: 'Deleted the post', deleteDiary: deleteDiary }
          else
            render status: 400, json: { status: 'Erroy', message: '例外処理' }
          end
        else
          render json: { status: 'Not Loggend in', message: "ログインしてください" }
        end
      end

      private
        def post_diary_params
          params.permit(:user_id, :title, :content, :emotion_id)
        end

        def post_edit_diary_params
          params.permit(:title, :content, :emotion_id)
        end
    end
  end
end
