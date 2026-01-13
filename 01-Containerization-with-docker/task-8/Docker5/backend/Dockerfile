FROM python:3.15.0a3-alpine3.23
WORKDIR /lab-6
COPY . .
RUN pip install --no-cache-dir flask
EXPOSE 5000
CMD ["python", "app.py"]
