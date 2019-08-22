"""
Multilayer perceptron
"""

import tensorflow as tf
import numpy as np
import csv

data_date = '02_05_2019_22_49_08_avg'
predictions_file_name = 'predictions/predictions_' + data_date + '_N_20_20e6.txt'

input_data = list(csv.reader(open('input_data/input_' + data_date + '.txt')))
output_data = list(csv.reader(open('input_data/output_' + data_date + '.txt')))

# Defino los vectores con los que voy a entrenar a la red,
# tanto para la salida como para la entrada.
training_input = np.array(input_data, dtype=float)
training_output = np.array(output_data, dtype=float)

test_input = np.array(input_data[64:], dtype=float)
test_output = np.array(output_data[64:], dtype=float)

# Parameters
c = 0.001
training_epochs = 20000000
#batch_size = 30
display_step = 1000

# Network parameters
n_hidden = 20 # number of neurons for the hidden layer
n_input = 2
n_output = 2

# tf Graph input
X = tf.placeholder("float", [None, n_input])
Y = tf.placeholder("float", [None, n_output])

# Store layers weight & bias
weights = {
    'h1': tf.Variable(tf.random_normal([n_input, n_hidden])),
    'out': tf.Variable(tf.random_normal([n_hidden, n_output]))
}

biases = {
    'b1': tf.Variable(tf.random_normal([n_hidden])),
    'out': tf.Variable(tf.random_normal([n_output]))
}

# Create model
def multilayer_perceptron(x):
    # Hidden fully connected layer with 256 neurons
    layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
    layer_1 = tf.nn.tanh(layer_1)
    # Output fully connected layer with a neuron for each class
    out_layer = tf.matmul(layer_1, weights['out']) + biases['out']
    out_layer = tf.nn.tanh(out_layer)
    return out_layer

# Construct model
pred = multilayer_perceptron(X)

# Define loss and optimizer
loss_op = tf.reduce_mean(tf.squared_difference(pred, Y))
optimizer = tf.train.AdamOptimizer(learning_rate=c)
train_op = optimizer.minimize(loss_op)
# Initializing the variables
init = tf.global_variables_initializer()

# Launch the graph 
with tf.Session() as sess:
    sess.run(init)

    # Training cycle
    for epoch in range(training_epochs):
        avg_cost = 0.
        # Run optimization op (backprop) and cost op (to get loss value)
        _, avg_cost = sess.run([train_op, loss_op], feed_dict={X: training_input, Y: training_output})
        # Display logs per epoch step
        if epoch % display_step == 0:
            print("epoch={:d}".format(epoch))
            print("cost={:.9f}".format(avg_cost))

        # Display logs per epoch step
        if epoch == training_epochs -1:
            predictions = pred.eval(feed_dict = {X: training_input})
            np.savetxt(predictions_file_name, predictions, delimiter=",")

    print("Optimization Finished!")

    # Test model
    mse = tf.metrics.mean_squared_error(pred,Y)
    print ("mse:", mse)

"""
# Test model
correct_prediction = tf.equal(tf.argmax(pred), tf.argmax(Y))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
print ("Accuracy:", accuracy.eval({X: training_input, Y: training_output}))



t = tf.constant([[1, 2, 3], [4, 5, 6], [7, 8, 9], [2, 3, 4]])

sess = tf.Session()

print (sess.run(tf.shape(t)))
print (sess.run(tf.size(t)))
print (sess.run(tf.rank(t)))
"""