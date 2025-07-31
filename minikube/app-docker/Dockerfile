FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -U pip && pip install flask gunicorn

EXPOSE 5000

CMD ["gunicorn", "app:app", "-b 0:5000"]