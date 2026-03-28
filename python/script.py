from tensorflow.keras.datasets import mnist
import numpy as np

# carregar dataset
(x_train, y_train), _ = mnist.load_data()

# pegar uma imagem
img = x_train[0]

# normalizar (0–255 → 0–15 ou 0–7)
img = (img / 16).astype(int)

# achatar (28x28 → 784)
flat = img.flatten()

# salvar .mem
with open("../data/input.mem", "w") as f:
    for val in flat:
        f.write(f"{val:02x}\n")

print("input.mem gerado!")