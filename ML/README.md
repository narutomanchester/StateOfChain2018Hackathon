# HashAds
Using KNN Classifier from tensorflow and use transfer learning method from existing image processing model then train some exercise movement. Here how to run:

## Use code
To use the code, first install the Javascript dependencies by running  

```
npm install
```

Then start the local budo web server by running 

```
npm start
```

This will start a web server on [`localhost:9966`](http://localhost:9966). Try and allow permission to your webcam, and add some examples by holding down the buttons. 

## Quick Reference - KNN Classifier
A quick overview of the most important function calls in the tensorflow.js [KNN Classifier](https://github.com/tensorflow/tfjs-models/tree/master/knn-classifier).

- `knnClassifier.create()`: Returns a KNNImageClassifier.

- `.addExample(example, classIndex)`: Adds an example to the specific class training set.

- `.clearClass(classIndex)`: Clears a specific class for training data.

- `.predictClass(image)`: Runs the prediction on the image, and returns an object with a top class index and confidence score. 

See the full implementation [here](https://github.com/tensorflow/tfjs-models/blob/master/knn-classifier/src/index.ts)

## Quick Reference - MobileNet
A quick overview of the most important function calls we use from the tensorflow.js model [MobileNet](https://github.com/tensorflow/tfjs-models/tree/master/mobilenet).

- `.load()`: Loads and returns a model object.

- `.infer(image, endpoint)`: Get an intermediate activation or logit as Tensorflow.js tensors. Takes an image and the optional endpoint to predict through.

See the full implementation [here](https://github.com/tensorflow/tfjs-models/blob/master/mobilenet/src/index.ts)
