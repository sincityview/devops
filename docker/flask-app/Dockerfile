FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install lsof curl build-essential libmariadb-dev -y
RUN pip install --no-cache-dir -U pip && pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["gunicorn", "app:app", "-b 0:8000"]