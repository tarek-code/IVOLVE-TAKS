FROM python:3.15.0a3-alpine3.23
WORKDIR /lab-6
COPY Docker-3/ .
RUN pip install --no-cache-dir flask
ENV APP_MODE=production
ENV APP_REGION=canada-west
EXPOSE 8080
CMD ["python", "app.py"]
