from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import (
    User,
    Plan,
    CoachProfile,
    PlanImage,
    Message,
    Conversation,
    TrainingSession,
    ClientTrainingLog,
    CoachClient,
)

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'password',
            'role',
            'phone',
            'speciality',
        ]

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()
    role = serializers.CharField()

    def validate(self, data):
        user = authenticate(
            username=data['username'],
            password=data['password']
        )

        if not user:
            raise serializers.ValidationError("Username ou password incorrect")

        if user.role != data['role']:
            raise serializers.ValidationError("Rôle incorrect")

        data['user'] = user
        return data


class PlanImageSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = PlanImage
        fields = ['id', 'image_url']

    def get_image_url(self, obj):
        request = self.context.get('request')

        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)

        if obj.image:
            return obj.image.url

        return None


class PlanSerializer(serializers.ModelSerializer):
    coach_name = serializers.SerializerMethodField()
    coach_speciality = serializers.SerializerMethodField()
    coach_photo_url = serializers.SerializerMethodField()
    coach_phone = serializers.SerializerMethodField()
    images = PlanImageSerializer(many=True, read_only=True)

    class Meta:
        model = Plan
        fields = [
            'id',
            'coach',
            'coach_name',
            'coach_speciality',
            'coach_photo_url',
            'coach_phone',
            'title',
            'category',
            'level',
            'price',
            'duration',
            'sessions_count',
            'description',
            'benefits',
            'images',
        ]

    def get_coach_profile(self, obj):
        return CoachProfile.objects.filter(user=obj.coach).first()

    def get_coach_name(self, obj):
        profile = self.get_coach_profile(obj)
        return profile.name if profile and profile.name else obj.coach.username

    def get_coach_speciality(self, obj):
        profile = self.get_coach_profile(obj)

        if profile and profile.speciality:
            return profile.speciality

        if obj.coach.speciality:
            return obj.coach.speciality

        return "Coach sportif"

    def get_coach_photo_url(self, obj):
        request = self.context.get('request')
        profile = self.get_coach_profile(obj)

        if profile and profile.photo:
            if request:
                return request.build_absolute_uri(profile.photo.url)
            return profile.photo.url

        return None

    def get_coach_phone(self, obj):
        return obj.coach.phone or ""


class CoachProfileSerializer(serializers.ModelSerializer):
    photo_url = serializers.SerializerMethodField()

    class Meta:
        model = CoachProfile
        fields = [
            'id',
            'user',
            'name',
            'speciality',
            'experience',
            'location',
            'bio',
            'photo',
            'photo_url',
        ]

    def get_photo_url(self, obj):
        request = self.context.get('request')

        if obj.photo and request:
            return request.build_absolute_uri(obj.photo.url)

        if obj.photo:
            return obj.photo.url

        return None


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(
        source="sender.username",
        read_only=True
    )

    class Meta:
        model = Message
        fields = [
            "id",
            "sender",
            "sender_name",
            "text",
            "created_at",
        ]


class ConversationSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)

    class Meta:
        model = Conversation
        fields = [
            "id",
            "client",
            "coach",
            "messages",
        ]
class TrainingSessionSerializer(serializers.ModelSerializer):
    coach_name = serializers.CharField(source="coach.username", read_only=True)
    plan_title = serializers.CharField(source="plan.title", read_only=True)

    class Meta:
        model = TrainingSession
        fields = [
            "id",
            "client",
            "coach",
            "coach_name",
            "plan",
            "plan_title",
            "title",
            "date",
            "time",
            "exercises",
            "status",
            "created_at",
        ]
class ClientTrainingLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClientTrainingLog
        fields = '__all__'
class CoachClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoachClient
        fields = '__all__'