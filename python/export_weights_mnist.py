import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten

# =========================
# 1. Carregar MNIST
# =========================
(x_train, y_train), _ = mnist.load_data()

x_train = x_train / 255.0

# =========================
# 2. Modelo simples
# =========================
model = Sequential([
    Flatten(input_shape=(28, 28)),
    Dense(10, activation='linear')  # sem ReLU!
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

model.fit(x_train, y_train, epochs=5)

# =========================
# 3. Extrair pesos
# =========================
weights, bias = model.layers[1].get_weights()

# =========================
# 4. Quantização (MUITO IMPORTANTE)
# =========================
SCALE = 64

weights_q = np.clip(weights * SCALE, -128, 127).astype(np.int8)
bias_q = np.clip(bias * SCALE, -128, 127).astype(np.int8)

# =========================
# 5. Exportar pesos
# =========================
for n in range(10):
    with open(f"../data/weights_n{n}.mem", "w") as f:
        for i in range(784):
            val = weights_q[i][n]
            f.write(f"{val & 0xff:02x}\n")

# =========================
# 6. Exportar bias
# =========================
with open("../data/bias.mem", "w") as f:
    for b in bias_q:
        f.write(f"{b & 0xff:02x}\n")

print("Pesos reais exportados!")