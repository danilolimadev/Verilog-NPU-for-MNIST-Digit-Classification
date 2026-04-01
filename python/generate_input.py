from tensorflow.keras.datasets import mnist
import numpy as np
import matplotlib.pyplot as plt

# =========================
# CARREGAR MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

print("===================================")
print("Gerando inputs de 0 a 9")
print("===================================")

# =========================
# LOOP PARA 0–9
# =========================
for digit in range(10):

    # pega um exemplo daquele dígito
    idx = np.where(y_train == digit)[0][0]

    img = x_train[idx]
    label = y_train[idx]

    print("\n-----------------------------------")
    print(f"Imagem escolhida: {idx}")
    print(f"Label real: {label}")
    print("-----------------------------------")

    # =========================
    # SEM NORMALIZAÇÃO (0–255)
    # =========================
    img = img.astype(int)

    # =========================
    # DEBUG
    # =========================
    print("Min pixel:", img.min())
    print("Max pixel:", img.max())

    if img.max() <= 15:
        print("❌ ERRO: escala errada")
    else:
        print("✅ Escala correta (0–255)")

    # =========================
    # MOSTRAR IMAGEM (🔥 AGORA SEMPRE)
    # =========================
    plt.figure(figsize=(3,3))
    plt.imshow(img, cmap='gray')
    plt.title(f"Digit: {label} (idx={idx})")
    plt.axis('off')
    plt.show()

    # =========================
    # FLATTEN
    # =========================
    flat = img.flatten()

    print("Primeiros 20 valores:")
    print(flat[:20])

    # =========================
    # SALVAR .mem
    # =========================
    filename = f"../data/input_{digit}.mem"

    with open(filename, "w") as f:
        for val in flat:
            f.write(f"{val:02x}\n")

    print(f"✅ Arquivo salvo: input_{digit}.mem")

print("\n===================================")
print("TODOS OS INPUTS GERADOS COM SUCESSO")
print("===================================")