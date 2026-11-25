# Databricks notebook source
import mlflow
from mlflow.genai.scorers import Correctness, RelevanceToQuery, Safety

eval_data = [
    {"inputs": {"question": "What was net revenue for the West region last quarter?"},
     "expectations": {"expected_response": "Net revenue for West was $4.2 million."}},
    {"inputs": {"question": "Which stores missed their March target?"},
     "expectations": {"expected_response": "Stores 112 and 147 missed their March target."}},
]

results = mlflow.genai.evaluate(
    data=eval_data,
    predict_fn=my_agent,  # your agent: takes a question, returns its answer
    scorers=[Correctness(), RelevanceToQuery(), Safety()],
)
