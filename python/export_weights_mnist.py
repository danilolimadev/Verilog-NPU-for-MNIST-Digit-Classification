import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten

# =========================
# 1. Carregar MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

# 🔥 Normalização (igual ao treino original)
x_train = x_train / 255.0

# =========================
# 2. Modelo (ALINHADO COM HARDWARE)
# =========================
model = Sequential([
    Flatten(input_shape=(28, 28)),
    Dense(10, activation='relu')  # 🔥 IMPORTANTE (igual ao hardware)
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

print("\nTreinando modelo...")
model.fit(x_train, y_train, epochs=5)

# =========================
# 3. Extrair pesos
# =========================
weights, bias = model.layers[1].get_weights()

print("\nPesos float (exemplo):")
print(weights[:5, :3])

print("\nBias float:")
print(bias)

# =========================
# 4. QUANTIZAÇÃO CORRETA
# =========================
# 🔥 Ajuste crítico: compensar entrada 0–255 do hardware
SCALE = 64 / 255.0

weights_q = np.clip(weights * SCALE, -128, 127).astype(np.int8)
bias_q = np.clip(bias * SCALE, -128, 127).astype(np.int8)

print("\nPesos quantizados (exemplo):")
print(weights_q[:5, :3])

print("\nBias quantizado:")
print(bias_q)

# =========================
# 5. EXPORTAR PESOS
# =========================
print("\nSalvando arquivos .mem...")

for n in range(10):
    with open(f"../data/weights_n{n}.mem", "w") as f:
        for i in range(784):
            val = weights_q[i][n]
            f.write(f"{val & 0xff:02x}\n")

# =========================
# 6. EXPORTAR BIAS
# =========================
with open("../data/bias.mem", "w") as f:
    for b in bias_q:
        f.write(f"{b & 0xff:02x}\n")

print("✅ Pesos e bias exportados com sucesso!")

# =========================
# 7. TESTE RÁPIDO NO PYTHON
# =========================
# só pra garantir que o modelo está funcionando

idx = 10
img = x_train[idx].reshape(1, 28, 28)

pred = model.predict(img)
digit = np.argmax(pred)

print("\n===================================")
print(f"Teste rápido com índice {idx}")
print(f"Label real: {y_train[idx]}")
print(f"Predição: {digit}")
print("===================================")