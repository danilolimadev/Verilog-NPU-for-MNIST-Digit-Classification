from tensorflow.keras.datasets import mnist
import numpy as np
import matplotlib.pyplot as plt

# =========================
# ESCOLHA AQUI
# =========================
INDEX = 10  # 🔥 MUDE PARA TESTAR

# =========================
# CARREGAR MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

img = x_train[INDEX]
label = y_train[INDEX]

print("===================================")
print(f"Imagem escolhida: {INDEX}")
print(f"Label real: {label}")
print("===================================")

# =========================
# NORMALIZAÇÃO CORRETA
# =========================
# 🔥 NÃO ESCALAR MAIS!
img = img.astype(int)

# =========================
# DEBUG (CRÍTICO)
# =========================
print("Min pixel:", img.min())
print("Max pixel:", img.max())

if img.max() <= 15:
    print("❌ ERRO: imagem ainda está em escala 0–15")
else:
    print("✅ Escala correta (0–255)")

# =========================
# MOSTRAR IMAGEM (opcional)
# =========================
plt.imshow(img, cmap='gray')
plt.title(f"Label: {label}")
plt.show()

# =========================
# FLATTEN
# =========================
flat = img.flatten()

print("\nPrimeiros 20 valores:")
print(flat[:20])

# =========================
# SALVAR .mem
# =========================
with open("../data/input.mem", "w") as f:
    for val in flat:
        f.write(f"{val:02x}\n")

print("\n✅ input.mem atualizado com sucesso!")