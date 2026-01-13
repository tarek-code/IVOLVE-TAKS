FROM python:3.15.0a3-alpine3.23
WORKDIR /frontend
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
ENTRYPOINT ["python","app.py"]
