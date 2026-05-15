from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    ROLE_CHOICES = (
        ('client', 'Client'),
        ('coach', 'Coach'),
    )

    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    phone = models.CharField(max_length=20, blank=True, null=True)
    speciality = models.CharField(max_length=100, blank=True, null=True)

    def __str__(self):
        return f"{self.username} - {self.role}"


class CoachProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100, blank=True, default="")
    speciality = models.CharField(max_length=150, blank=True, default="")
    experience = models.CharField(max_length=100, blank=True, default="")
    location = models.CharField(max_length=150, blank=True, default="")
    bio = models.TextField(blank=True, default="")
    photo = models.ImageField(upload_to='coach_photos/', blank=True, null=True)

    def __str__(self):
        return self.name if self.name else self.user.username


class Plan(models.Model):
    LEVEL_CHOICES = (
        ('basic', 'Basic'),
        ('premium', 'Premium'),
        ('elite', 'Elite'),
    )

    CATEGORY_CHOICES = (
        ('box', 'Box'),
        ('musculation', 'Musculation'),
        ('yoga', 'Yoga'),
        ('crossfit', 'Crossfit'),
        ('fitness', 'Fitness'),
        ('cardio', 'Cardio'),
        ('autre', 'Autre'),
    )

    coach = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='autre')
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES, default='basic')
    price = models.FloatField()
    duration = models.CharField(max_length=100, blank=True, default="")
    sessions_count = models.IntegerField(default=0)
    description = models.TextField()
    benefits = models.TextField(blank=True, default="")

    def __str__(self):
        return f"{self.title} - {self.price} DT"


class PlanImage(models.Model):
    plan = models.ForeignKey(
        Plan,
        on_delete=models.CASCADE,
        related_name="images"
    )
    image = models.ImageField(upload_to="plans/images/")

    def __str__(self):
        return f"Image de {self.plan.title}"
class Conversation(models.Model):
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name="client_conversations")
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name="coach_conversations")
    created_at = models.DateTimeField(auto_now_add=True)


class Message(models.Model):
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(User, on_delete=models.CASCADE)
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
class TrainingSession(models.Model):
    STATUS_CHOICES = [
        ("planned", "Planned"),
        ("done", "Done"),
    ]

    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name="training_sessions")
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name="coach_training_sessions")
    plan = models.ForeignKey(Plan, on_delete=models.SET_NULL, null=True, blank=True)

    title = models.CharField(max_length=150)
    date = models.DateField()
    time = models.TimeField()
    exercises = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="planned")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

class ClientTrainingLog(models.Model):
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name="training_logs")

    date = models.DateField()
    time = models.TimeField()

    weight = models.FloatField(null=True, blank=True)
    height = models.FloatField(null=True, blank=True)

    exercises = models.TextField()
    notes = models.TextField(blank=True)
    goal = models.CharField(max_length=200, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.client.username} - {self.date}"
class CoachClient(models.Model):
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name="my_clients")

    client_name = models.CharField(max_length=120)
    phone = models.CharField(max_length=30, blank=True)

    goal = models.CharField(max_length=200)

    total_sessions = models.IntegerField(default=0)
    done_sessions = models.IntegerField(default=0)

    paid = models.BooleanField(default=False)

    next_session_date = models.DateField(null=True, blank=True)
    next_session_time = models.TimeField(null=True, blank=True)

    notes = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)