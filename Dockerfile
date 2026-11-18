FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV APP_PORT=5001 PYTHONDONTWRITEBYTECODE=1
EXPOSE 5001
CMD ["python", "app.py"]

ARG VERSION=dev
RUN printf '%s\n' "$VERSION" > /app/VERSION
