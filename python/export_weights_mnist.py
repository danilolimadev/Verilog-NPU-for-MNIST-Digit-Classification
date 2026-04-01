import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten

# =========================
# 1. LOAD DATA
# =========================
(x_train, y_train), _ = mnist.load_data()

# 🔥 IMPORTANTE: SEM NORMALIZAÇÃO (0–255 igual hardware)
x_train = x_train.astype(np.float32)

print("Dataset carregado")
print("Min:", x_train.min(), "Max:", x_train.max())

# =========================
# 2. MODELO (ALINHADO COM HW)
# =========================
model = Sequential([
    Flatten(input_shape=(28, 28)),
    Dense(10, activation='linear')  # 🔥 SEM RELU
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

print("\nTreinando modelo...")
model.fit(x_train, y_train, epochs=5)

# =========================
# 3. EXTRAIR PESOS
# =========================
weights, bias = model.layers[1].get_weights()

print("\nPesos float (amostra):")
print(weights[:5, :3])

print("\nBias float:")
print(bias)

# =========================
# 4. QUANTIZAÇÃO (ALINHADA AO HW)
# =========================
SCALE = 64  # 🔥 melhor match com entrada 0–255

weights_q = np.round(weights * SCALE)
bias_q = np.round(bias * SCALE)

weights_q = np.clip(weights_q, -128, 127).astype(np.int8)
bias_q = np.clip(bias_q, -128, 127).astype(np.int8)

print("\nPesos quantizados (amostra):")
print(weights_q[:5, :3])

print("\nBias quantizado:")
print(bias_q)

# =========================
# 5. EXPORTAR PESOS
# =========================
print("\nSalvando weights...")

for n in range(10):
    with open(f"../data/weights_n{n}.mem", "w") as f:
        for i in range(784):
            val = weights_q[i][n]
            f.write(f"{val & 0xff:02x}\n")

# =========================
# 6. EXPORTAR BIAS
# =========================
print("Salvando bias...")

with open("../data/bias.mem", "w") as f:
    for b in bias_q:
        f.write(f"{b & 0xff:02x}\n")

print("✅ Pesos e bias exportados!")

# =========================
# 7. TESTE FLOAT (REFERÊNCIA)
# =========================
idx = 10
img = x_train[idx].reshape(1, 28, 28)

pred = model.predict(img)
digit = np.argmax(pred)

print("\n==== TESTE FLOAT ====")
print("Real:", y_train[idx])
print("Pred:", digit)

# =========================
# 8. TESTE QUANTIZADO (SIMULA HW)
# =========================
flat = x_train[idx].flatten()

acc = np.zeros(10)

for i in range(784):
    for n in range(10):
        acc[n] += flat[i] * weights_q[i][n]

# adiciona bias
acc += bias_q

digit_q = np.argmax(acc)

print("\n==== TESTE QUANTIZADO (HW SIM) ====")
print("Pred:", digit_q)
print("Scores:", acc.astype(int))

print("\n===================================")