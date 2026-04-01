import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten

# =========================
# LOAD
# =========================
(x_train, y_train), _ = mnist.load_data()
x_train = x_train.astype(np.float32)

# =========================
# MODELO CORRETO
# =========================
model = Sequential([
    Flatten(input_shape=(28, 28)),
    Dense(10, activation=None)  # 🔥 SEM RELU
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

print("Treinando...")
model.fit(x_train, y_train, epochs=5)

# =========================
# PESOS
# =========================
weights, bias = model.layers[1].get_weights()

# =========================
# QUANTIZAÇÃO MELHOR
# =========================
SCALE = 32

weights_q = np.clip(weights * SCALE, -128, 127).astype(np.int8)
bias_q = np.clip(bias * SCALE, -128, 127).astype(np.int8)

# =========================
# EXPORT
# =========================
for n in range(10):
    with open(f"../data/weights_n{n}.mem", "w") as f:
        for i in range(784):
            f.write(f"{weights_q[i][n] & 0xff:02x}\n")

with open("../data/bias.mem", "w") as f:
    for b in bias_q:
        f.write(f"{b & 0xff:02x}\n")

print("OK!")

# =========================
# TESTE
# =========================
idx = 10
img = x_train[idx].reshape(1, 28, 28)

pred = model.predict(img)
print("Real:", y_train[idx])
print("Pred:", np.argmax(pred))