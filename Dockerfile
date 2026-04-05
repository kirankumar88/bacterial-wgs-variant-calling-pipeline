FROM continuumio/miniconda3

WORKDIR /app

COPY environment.yml .
RUN conda env create -f environment.yml

SHELL ["conda", "run", "-n", "bacterial_variant_pipeline", "/bin/bash", "-c"]

COPY . .

RUN mkdir -p data reference qc alignment variants annotation results logs

EXPOSE 8501

CMD ["conda", "run", "-n", "bacterial_variant_pipeline", "streamlit", "run", "streamlit_app/app.py", "--server.port=8501", "--server.address=0.0.0.0"]