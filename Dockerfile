# Use the official Python image as the base image
FROM python:3.10

# Prevent Python from writing .pyc files to disk
ENV PYTHONDONTWRITEBYTECODE 1

# Prevent Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1

# Set the working directory to /app
WORKDIR /app

# Copy the requirements file to the working directory
COPY backend/requirements.txt /app/

# Install dependencies without caching for smaller image size
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire backend directory into the container
COPY backend /app/

# Run migrations as part of the container's startup process
CMD ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
