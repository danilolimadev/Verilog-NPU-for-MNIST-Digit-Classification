from tensorflow.keras.datasets import mnist
import numpy as np

# =========================
# ESCOLHA AQUI
# =========================
INDEX = 10   # 🔥 MUDE ISSO PRA TESTAR

# =========================
# CARREGAR MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

img = x_train[INDEX]
label = y_train[INDEX]

print(f"Imagem escolhida: {INDEX}")
print(f"Label real: {label}")

# =========================
# NORMALIZAÇÃO (IMPORTANTE)
# =========================
img = (img / 16).astype(int)

# =========================
# SALVAR .mem
# =========================
flat = img.flatten()

with open("../data/input.mem", "w") as f:
    for val in flat:
        f.write(f"{val:02x}\n")

print("input.mem atualizado!")