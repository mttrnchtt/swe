# Generated by Django 5.1.3 on 2024-12-02 01:13

import apps.farm.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('farm', '0005_alter_farm_created_at_alter_farm_updated_at_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='productimage',
            name='image',
            field=models.ImageField(upload_to=apps.farm.models.ProductImage._file_path),
        ),
    ]
