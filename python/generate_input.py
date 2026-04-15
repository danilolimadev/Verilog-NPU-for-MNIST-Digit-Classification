from tensorflow.keras.datasets import mnist
import numpy as np
import matplotlib.pyplot as plt
import os

# =========================
# PASTAS
# =========================
img_dir = "mnist_numbers"
mem_dir = "../data"

os.makedirs(img_dir, exist_ok=True)
os.makedirs(mem_dir, exist_ok=True)

# =========================
# CARREGAR MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

# =========================
# LOOP POR DÍGITO
# =========================
for digit in range(10):

    # pega todos os índices daquele dígito
    indices = np.where(y_train == digit)[0]

    # escolhe UM aleatório
    idx = np.random.choice(indices)

    img = x_train[idx]

    # 🔥 NORMALIZAÇÃO PARA HARDWARE
    img_hw = (img >> 4).astype(int)

    print(f"\nDigit: {digit}")
    print("Min:", img_hw.min(), "Max:", img_hw.max())

    # =========================
    # SALVAR IMAGEM (debug)
    # =========================
    img_path = os.path.join(img_dir, f"digit_{digit}.png")
    plt.imsave(img_path, img, cmap='gray')

    # =========================
    # GERAR .mem
    # =========================
    flat = img_hw.flatten()
    mem_path = os.path.join(mem_dir, f"input_{digit}.mem")

    with open(mem_path, "w") as f:
        for val in flat:
            f.write(f"{val:02x}\n")

    print(f"Imagem: {img_path}")
    print(f".mem  : {mem_path}")