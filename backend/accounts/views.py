from rest_framework.decorators import api_view, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.response import Response
from rest_framework import status
from .models import ClientTrainingLog
from rest_framework import serializers
import json

from .models import User, Plan, CoachProfile, PlanImage, Message, Conversation, TrainingSession, ClientTrainingLog,CoachClient
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    PlanSerializer,
    CoachProfileSerializer,
    ConversationSerializer,
    MessageSerializer,
    ClientTrainingLogSerializer,
    CoachClientSerializer,
)

@api_view(['POST'])
def register_user(request):
    serializer = RegisterSerializer(data=request.data)

    if serializer.is_valid():
        user = serializer.save()
        return Response({
            "message": "User créé avec succès",
            "user_id": user.id,
            "role": user.role
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def login_user(request):
    serializer = LoginSerializer(data=request.data)

    if serializer.is_valid():
        user = serializer.validated_data['user']
        return Response({
            "message": "Login succès",
            "user_id": user.id,
            "username": user.username,
            "role": user.role,
            "email": user.email,
            "phone": user.phone,
            "speciality": user.speciality,
        })

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def get_plans(request):
    coach_id = request.GET.get("coach")
    category = request.GET.get("category")

    plans = Plan.objects.filter(coach__role="coach")

    if coach_id:
        plans = plans.filter(coach_id=coach_id)

    # filtre par spécialité du coach
    if category:
        plans = (
            plans.filter(coach__coachprofile__speciality__iexact=category)
            | plans.filter(coach__speciality__iexact=category)
        )

    plans = plans.distinct().order_by("-id")

    serializer = PlanSerializer(
        plans,
        many=True,
        context={"request": request}
    )

    return Response(serializer.data)


@api_view(['GET'])
def get_plan_categories(request):
    categories = [
        {"value": "Fitness", "label": "Fitness"},
        {"value": "Musculation", "label": "Musculation"},
        {"value": "Boxe", "label": "Boxe"},
        {"value": "Yoga", "label": "Yoga"},
    ]
    return Response(categories)


@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser, JSONParser])
def create_plan(request):
    coach_id = request.data.get("coach")

    try:
        coach = User.objects.get(id=coach_id, role="coach")
    except User.DoesNotExist:
        return Response(
            {"error": "Coach introuvable ou utilisateur n'est pas coach"},
            status=status.HTTP_400_BAD_REQUEST
        )

    data = request.data.copy()
    data["coach"] = coach.id

    # optionnel : catégorie du forfait = spécialité du coach
    if not data.get("category"):
        profile = CoachProfile.objects.filter(user=coach).first()
        data["category"] = (
            profile.speciality
            if profile and profile.speciality
            else coach.speciality or "autre"
        )

    serializer = PlanSerializer(
        data=data,
        context={"request": request}
    )

    if serializer.is_valid():
        plan = serializer.save()

        images = request.FILES.getlist("images")
        for image in images:
            PlanImage.objects.create(plan=plan, image=image)

        serializer = PlanSerializer(plan, context={"request": request})

        return Response({
            "message": "Plan créé avec succès",
            "plan": serializer.data
        }, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser, JSONParser])
def save_coach_profile(request):
    user_id = request.data.get("user")

    if not user_id:
        return Response(
            {"error": "user id obligatoire"},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.get(id=user_id, role="coach")
    except User.DoesNotExist:
        return Response(
            {"error": "Coach introuvable"},
            status=status.HTTP_404_NOT_FOUND
        )

    profile, created = CoachProfile.objects.get_or_create(user=user)

    profile.name = request.data.get("name", profile.name)
    profile.speciality = request.data.get("speciality", profile.speciality)
    profile.experience = request.data.get("experience", profile.experience)
    profile.location = request.data.get("location", profile.location)
    profile.bio = request.data.get("bio", profile.bio)

    if request.FILES.get("photo"):
        profile.photo = request.FILES.get("photo")

    profile.save()

    # garder la spécialité aussi dans User
    user.speciality = profile.speciality
    user.save()

    serializer = CoachProfileSerializer(
        profile,
        context={"request": request}
    )

    return Response({
        "message": "Profil coach sauvegardé avec succès",
        "profile": serializer.data
    })


@api_view(['GET'])
def get_coach_profile(request, user_id):
    try:
        profile = CoachProfile.objects.get(user_id=user_id)
    except CoachProfile.DoesNotExist:
        return Response({
            "error": "Profil coach introuvable"
        }, status=status.HTTP_404_NOT_FOUND)

    serializer = CoachProfileSerializer(
        profile,
        context={"request": request}
    )

    return Response(serializer.data)


@api_view(['PUT', 'PATCH'])
@parser_classes([MultiPartParser, FormParser, JSONParser])
def update_plan(request, plan_id):
    try:
        plan = Plan.objects.get(id=plan_id)
    except Plan.DoesNotExist:
        return Response(
            {"error": "Forfait introuvable"},
            status=status.HTTP_404_NOT_FOUND
        )

    serializer = PlanSerializer(
        plan,
        data=request.data,
        partial=True,
        context={"request": request}
    )

    if serializer.is_valid():
        plan = serializer.save()

        remaining_images = request.data.get("remaining_images")

        if remaining_images is not None:
            remaining_ids = json.loads(remaining_images)
            plan.images.exclude(id__in=remaining_ids).delete()

        images = request.FILES.getlist("images")

        for image in images:
            PlanImage.objects.create(plan=plan, image=image)

        serializer = PlanSerializer(plan, context={"request": request})

        return Response({
            "message": "Forfait modifié avec succès",
            "plan": serializer.data
        }, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
@api_view(['DELETE'])
def delete_plan(request, plan_id):
    try:
        plan = Plan.objects.get(id=plan_id)
    except Plan.DoesNotExist:
        return Response(
            {"error": "Forfait introuvable"},
            status=status.HTTP_404_NOT_FOUND
        )

    plan.delete()

    return Response(
        {"message": "Forfait supprimé avec succès"},
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
def create_conversation(request):
    client_id = request.data.get("client")
    coach_id = request.data.get("coach")

    convo = Conversation.objects.filter(
        client_id=client_id,
        coach_id=coach_id
    ).first()

    if not convo:
        convo = Conversation.objects.create(
            client_id=client_id,
            coach_id=coach_id
        )

    serializer = ConversationSerializer(convo)
    return Response(serializer.data)


@api_view(['GET'])
def get_messages(request, conversation_id):
    messages = Message.objects.filter(
        conversation_id=conversation_id
    ).order_by("created_at")

    serializer = MessageSerializer(messages, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def send_message(request):
    conversation_id = request.data.get("conversation")
    sender_id = request.data.get("sender")
    text = request.data.get("text")

    message = Message.objects.create(
        conversation_id=conversation_id,
        sender_id=sender_id,
        text=text
    )

    serializer = MessageSerializer(message)
    return Response(serializer.data)


@api_view(['GET'])
def coach_conversations(request, coach_id):
    conversations = Conversation.objects.filter(
        coach_id=coach_id
    ).order_by("-created_at")

    serializer = ConversationSerializer(conversations, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def client_conversations(request, client_id):
    conversations = Conversation.objects.filter(
        client_id=client_id
    ).order_by("-created_at")

    serializer = ConversationSerializer(conversations, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def client_training_sessions(request, client_id):
    sessions = TrainingSession.objects.filter(
        client_id=client_id
    ).order_by("date", "time")

    serializer = TrainingSessionSerializer(sessions, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_training_session(request):
    serializer = TrainingSessionSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PATCH'])
def mark_training_done(request, session_id):
    try:
        session = TrainingSession.objects.get(id=session_id)
    except TrainingSession.DoesNotExist:
        return Response({"error": "Séance introuvable"}, status=404)

    session.status = "done"
    session.save()

    serializer = TrainingSessionSerializer(session)
    return Response(serializer.data)
@api_view(['GET'])
def client_training_logs(request, client_id):
    logs = ClientTrainingLog.objects.filter(
        client_id=client_id
    ).order_by("-date", "-time")

    serializer = ClientTrainingLogSerializer(logs, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_training_log(request):
    serializer = ClientTrainingLogSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def delete_training_log(request, log_id):
    try:
        log = ClientTrainingLog.objects.get(id=log_id)
    except ClientTrainingLog.DoesNotExist:
        return Response({"error": "Log introuvable"}, status=404)

    log.delete()
    return Response({"message": "Training log supprimé"})
@api_view(['GET'])
def coach_clients(request, coach_id):
    clients = CoachClient.objects.filter(coach_id=coach_id)
    serializer = CoachClientSerializer(clients, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_coach_client(request):
    serializer = CoachClientSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)

    return Response(serializer.errors, status=400)


@api_view(['PATCH'])
def update_coach_client(request, client_id):
    try:
        client = CoachClient.objects.get(id=client_id)
    except CoachClient.DoesNotExist:
        return Response({"error": "not found"}, status=404)

    serializer = CoachClientSerializer(client, data=request.data, partial=True)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)

    return Response(serializer.errors, status=400)


@api_view(['DELETE'])
def delete_coach_client(request, client_id):
    try:
        client = CoachClient.objects.get(id=client_id)
        client.delete()
        return Response({"message": "deleted"})
    except:
        return Response({"error": "not found"}, status=404)