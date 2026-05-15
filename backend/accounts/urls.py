from django.urls import path
from . import views   # ← IMPORTANT

urlpatterns = [
    path('register/', views.register_user),
    path('login/', views.login_user),

    path('plans/categories/', views.get_plan_categories),
    path('plans/', views.get_plans),
    path('plans/create/', views.create_plan),

    path('plans/<int:plan_id>/update/', views.update_plan),
    path('plans/<int:plan_id>/delete/', views.delete_plan),

    path('coach-profile/save/', views.save_coach_profile),
    path('coach-profile/<int:user_id>/', views.get_coach_profile),
    path('chat/create/', views.create_conversation),
    path('chat/messages/<int:conversation_id>/', views.get_messages),
    path('chat/send/', views.send_message),
    path('chat/coach/<int:coach_id>/', views.coach_conversations),
    path('chat/client/<int:client_id>/', views.client_conversations),
  path('training/client/<int:client_id>/', views.client_training_logs),
path('training/create/', views.create_training_log),
path('training/<int:log_id>/delete/', views.delete_training_log),
path('coach/clients/<int:coach_id>/', views.coach_clients),
path('coach/clients/create/', views.create_coach_client),
path('coach/clients/<int:client_id>/update/', views.update_coach_client),
path('coach/clients/<int:client_id>/delete/', views.delete_coach_client),
]