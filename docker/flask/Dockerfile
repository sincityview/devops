FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install build-essential libmariadb-dev -y
RUN pip install --no-cache-dir -U pip && pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "app:app", "-b 0:5000"]