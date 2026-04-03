import numpy as np
import os

# =========================
# PATH
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "..", "data")

# =========================
# Utils
# =========================
def hex_to_int8(hex_str):
    val = int(hex_str, 16)
    if val > 127:
        val -= 256
    return val

def load_mem_file(path):
    with open(path, "r") as f:
        return [line.strip() for line in f.readlines()]

# =========================
# LOAD INPUT
# =========================
def load_input(file_name):
    path = os.path.join(DATA_DIR, file_name)
    data = load_mem_file(path)
    return np.array([int(x, 16) for x in data], dtype=np.int32)

# =========================
# LOAD WEIGHTS
# =========================
def load_weights():
    weights = []
    for n in range(10):
        file_path = os.path.join(DATA_DIR, f"weights_n{n}.mem")
        data = load_mem_file(file_path)
        w = np.array([hex_to_int8(x) for x in data], dtype=np.int32)
        weights.append(w)
    return weights

# =========================
# LOAD BIAS
# =========================
def load_bias():
    data = load_mem_file(os.path.join(DATA_DIR, "bias.mem"))
    return np.array([hex_to_int8(x) for x in data], dtype=np.int32)

# =========================
# INFERÊNCIA
# =========================
def predict(input_vec, weights, bias):
    logits = []

    for n in range(10):
        acc = np.sum(input_vec * weights[n]) + bias[n]
        logits.append(acc)

    logits = np.array(logits)
    pred = np.argmax(logits)

    return pred, logits

# =========================
# TESTE PARA TODAS ENTRADAS
# =========================
if __name__ == "__main__":

    weights = load_weights()
    bias = load_bias()

    correct = 0

    for digit in range(10):
        input_file = f"input_{digit}.mem"

        x = load_input(input_file)

        pred, logits = predict(x, weights, bias)

        print(f"\nEntrada: {digit}")
        print(f"Predição: {pred}")
        print(f"Logits: {logits}")

        if pred == digit:
            print("✔ Correto")
            correct += 1
        else:
            print("❌ Errado")

    print("\n======================")
    print(f"Acurácia: {correct}/10")