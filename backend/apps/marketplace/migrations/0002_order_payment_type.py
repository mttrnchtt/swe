# Generated by Django 5.1.3 on 2024-12-02 04:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('marketplace', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='payment_type',
            field=models.CharField(choices=[('cash_on_delivery', 'Cash on Delivery'), ('credit_card', 'Credit Card'), ('mobile_payment', 'Mobile Payment')], default='cash_on_delivery', max_length=20),
        ),
    ]
