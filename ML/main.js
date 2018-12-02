// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "@babel/polyfill";
import * as mobilenetModule from '@tensorflow-models/mobilenet';
import * as tf from '@tensorflow/tfjs';
import * as knnClassifier from '@tensorflow-models/knn-classifier';
import * as firebase from 'firebase';
import * as ethers from 'ethers';

// Number of classes to classify
const NUM_CLASSES = 6;
// Webcam Image size. Must be 227.
const IMAGE_SIZE = 227;
// K value for KNN
const TOPK = 10;

const privatekey = "d0501a7a13847019cae84c664cea87add61937214f7c1862e47f556fe58dda91";
const address = "0x08856F81cD92b31164bE4DE0847a4763CA4Aa10b";


const POSE_NAME = ['EMPTY','STAND ONLY', 'ARMS OPEN', 'DIAGONAL', 'HANDS ON CHEST', 'LOVE'];
var MOVEMENT = {
    empty: 0,
    stand_only: 1,
    arms_open: 2,
    diagonal: 3,
    hands_on_chest: 4,
    love: 5
};

var EXERCISE = {
  open_close_arms: 0,
  diagonal: 0,
  love: 0
}

var datasetNumber = 0;


class Main {
  constructor() {
    // Initiate variables
    this.infoTexts = [];
    this.training = -1; // -1 when no class is being trained
    this.videoPlaying = false;

    // Initiate deeplearn.js math and knn classifier objects
    this.bindPage();

    // Create video element that will contain the webcam image
    this.video = document.createElement('video');
    this.video.setAttribute('autoplay', '');
    this.video.setAttribute('playsinline', '');

    // Add video element to DOM
    document.body.appendChild(this.video);

    // Create training buttons and info texts
    for (let i = 0; i < NUM_CLASSES; i++) {
      const div = document.createElement('div');
      document.body.appendChild(div);
      div.style.marginBottom = '10px';

      // Create training button
      const button = document.createElement('button')
      button.innerText = "Train " + i;
      div.appendChild(button);

      // Listen for mouse events when clicking the button
      button.addEventListener('mousedown', () => this.training = i);
      button.addEventListener('mouseup', () => this.training = -1);

      // Create info text
      const infoText = document.createElement('span')
      infoText.innerText = POSE_NAME[i];
      div.appendChild(infoText);
      this.infoTexts.push(infoText);
      this.startDate = new Date();
    }

    const exitDiv = document.createElement('div');
    document.body.appendChild(exitDiv);
    exitDiv.style.marginBottom = '10px';

    const exitButton = document.createElement('button')
    exitButton.innerText = "Done";
    exitDiv.appendChild(exitButton);

    exitButton.addEventListener('click', () => {
      this.setFirebaseState(false);
      var total = EXERCISE.open_close_arms + EXERCISE.up_and_open_arms + EXERCISE.love;
      this.ethSync('ExerciseProof', 0, total, 'https://hashads-7968e.firebaseio.com/test.json', 'a4763CA4Aa10b');
    });


    /*const exerciseText = document.createElement('span')
    exerciseText.innerText = 'Number of Exercise';
    div.appendChild(exerciseText);
    this.infoTexts.push(exerciseText)
    */

    // Setup webcam
    navigator.mediaDevices.getUserMedia({ video: true, audio: false })
      .then((stream) => {
        this.video.srcObject = stream;
        this.video.width = IMAGE_SIZE;
        this.video.height = IMAGE_SIZE;

        this.video.addEventListener('playing', () => this.videoPlaying = true);
        this.video.addEventListener('paused', () => this.videoPlaying = false);
      })
    this.initializeFirebase();
    this.setFirebaseState(true);
  }

  async bindPage() {
    this.knn = knnClassifier.create();
    this.mobilenet = await mobilenetModule.load();

    this.start();
  }

  start() {
    if (this.timer) {
      this.stop();
    }
    this.video.play();
    this.timer = requestAnimationFrame(this.animate.bind(this));
  }

  stop() {
    this.video.pause();
    cancelAnimationFrame(this.timer);
  }

  async animate() {
    if (this.videoPlaying) {
      // Get image data from video element
      const image = tf.fromPixels(this.video);

      let logits;
      // 'conv_preds' is the logits activation of MobileNet.
      const infer = () => this.mobilenet.infer(image, 'conv_preds');

      // Train class if one of the buttons is held down
      if (this.training != -1) {
        logits = infer();
        //
        // Add current image to classifier
        datasetNumber++;
        //if (datasetNumber == 10) {
          /*console.log('this.knn.getClassifierDataset()');
          console.log(this.knn.getClassifierDataset());
          console.log('this.knn');
          console.log(this.knn);
          */
          //classifier.getClassifierDataset();
          //const saveResult = await this.knn.model.save('localstorage://my-model-1');
        //}
        this.knn.addExample(logits, this.training)
      }

      const numClasses = this.knn.getNumClasses();
      if (numClasses > 0) {

        // If classes have been added run predict
        logits = infer();
        const res = await this.knn.predictClass(logits, TOPK);

        for (let i = 0; i < NUM_CLASSES; i++) {

          // The number of examples for each class
          const exampleCount = this.knn.getClassExampleCount();

          // Make the predicted class bold
          if (res.classIndex == i) {
            this.infoTexts[i].style.fontWeight = 'bold';
            this.checkMovement(i);
            if (res.confidences[i] * 100 > 40 ) {
              this.lastPose = i;
            }
          } else {
            this.infoTexts[i].style.fontWeight = 'normal';
          }

          // Update info text
          if (exampleCount[i] > 0) {
            this.infoTexts[i].innerText = ` ${exampleCount[i]} ${POSE_NAME[i]} - ${res.confidences[i] * 100}%`
          }
        }
      }

      // Dispose image when done
      image.dispose();
      if (logits != null) {
        logits.dispose();
      }
    }
    this.timer = requestAnimationFrame(this.animate.bind(this));
  }

  async checkMovement(currentPose) {
    if (this.lastPose == MOVEMENT.diagonal && currentPose == MOVEMENT.arms_open) {
      EXERCISE.diagonal = EXERCISE.diagonal + 1;
    } else if (this.lastPose == MOVEMENT.hands_on_chest && currentPose == MOVEMENT.arms_open) {
      EXERCISE.open_close_arms = EXERCISE.open_close_arms + 1;
    } else if (this.lastPose == MOVEMENT.love && currentPose == MOVEMENT.arms_open) {
      EXERCISE.love = EXERCISE.love + 1;
    }

    console.log(this.numberOfExercise);
    this.writeToFirebase('randomThingToWrite');
  }



  async initializeFirebase() {
    var config = {
      apiKey: "AIzaSyDldzUpgJR34Kil7p0Eik8Ik3yBWMvsVc4",
      authDomain: "hashads-7968e.firebaseapp.com",
      databaseURL: "https://hashads-7968e.firebaseio.com",
      projectId: "hashads-7968e",
      storageBucket: "hashads-7968e.appspot.com",
      messagingSenderId: "981788474160"
    };
    firebase.initializeApp(config);

    // Get a reference to the database service
    this.firebaseDatabase = firebase.database();

  }

  async setFirebaseState(status){
    this.firebaseDatabase.ref('status').set(
      status
      , function(error) {
        if (error) {
          console.log('error');
          console.log(error);
        } else {
          console.log('success');
        };
    });
  }

  async writeToFirebase() {
    const currentDate = new Date().toISOString();
    const now = new Date();
    var totalSecond = now - this.startDate;
    console.log(totalSecond);
    const userId = 'default';
    var data = {
      diagonal: EXERCISE.diagonal,
      open_close_arms: EXERCISE.open_close_arms,
      love: EXERCISE.love
    }
      //firebase.database().ref('users/' + userId).set({
    this.firebaseDatabase.ref().child('test').set({
      userId: userId,
      createdDate: currentDate,
      totalSecond: Math.floor(totalSecond/1000),
      data : data
      }, function(error) {
        if (error) {
          console.log('error');
          console.log(error);
        } else {
          console.log('success');
        };
    });
  }

  //curl 'https://hashads-7968e.firebaseio.com/test.json
  //title: whatever
  //type : id of movement type
  //metadataURL : url to firebase
  async ethSync(title, type, score, metadataURL, metadataHash) {
   console.log('eth sync...')
   const contract = "0x7c76874a179c3171523fd7a6110944c1efd91a5f"
   const abi = [{
       "constant": false,
       "inputs": [{
           "name": "spender",
           "type": "address"
         },
         {
           "name": "value",
           "type": "uint256"
         }
       ],
       "name": "approve",
       "outputs": [{
         "name": "",
         "type": "bool"
       }],
       "payable": false,
       "stateMutability": "nonpayable",
       "type": "function"
     },
     {
       "constant": false,
       "inputs": [{
           "name": "_title",
           "type": "string"
         },
         {
           "name": "_type",
           "type": "int256"
         },
         {
           "name": "_score",
           "type": "uint256"
         },
         {
           "name": "_metadataURL",
           "type": "string"
         },
         {
           "name": "_metadataHash",
           "type": "string"
         }
       ],
       "name": "createActivity",
       "outputs": [],
       "payable": false,
       "stateMutability": "nonpayable",
       "type": "function"
     },
     {
       "constant": false,
       "inputs": [{
           "name": "_name",
           "type": "string"
         },
         {
           "name": "_symbol",
           "type": "string"
         },
         {
           "name": "_decimals",
           "type": "uint8"
         },
         {
           "name": "_amount",
           "type": "uint256"
         }
       ],
       "name": "initiateToken",
       "outputs": [],
       "payable": false,
       "stateMutability": "nonpayable",
       "type": "function"
     },
     {
       "constant": false,
       "inputs": [{
           "name": "to",
           "type": "address"
         },
         {
           "name": "value",
           "type": "uint256"
         }
       ],
       "name": "transfer",
       "outputs": [{
         "name": "",
         "type": "bool"
       }],
       "payable": false,
       "stateMutability": "nonpayable",
       "type": "function"
     },
     {
       "inputs": [],
       "payable": false,
       "stateMutability": "nonpayable",
       "type": "constructor"
     },
     {
       "constant": true,
       "inputs": [{
           "name": "owner",
           "type": "address"
         },
         {
           "name": "spender",
           "type": "address"
         }
       ],
       "name": "allowance",
       "outputs": [{
         "name": "",
         "type": "uint256"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [{
         "name": "owner",
         "type": "address"
       }],
       "name": "balanceOf",
       "outputs": [{
         "name": "",
         "type": "uint256"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [{
         "name": "",
         "type": "address"
       }],
       "name": "balances",
       "outputs": [{
         "name": "",
         "type": "uint256"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "decimals",
       "outputs": [{
         "name": "",
         "type": "uint8"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [{
         "name": "_id",
         "type": "uint256"
       }],
       "name": "getActivityById",
       "outputs": [{
           "name": "",
           "type": "address"
         },
         {
           "name": "",
           "type": "string"
         },
         {
           "name": "",
           "type": "int256"
         },
         {
           "name": "",
           "type": "uint256"
         }
       ],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "isTokenInitialized",
       "outputs": [{
         "name": "",
         "type": "bool"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "name",
       "outputs": [{
         "name": "",
         "type": "string"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "numActivity",
       "outputs": [{
         "name": "",
         "type": "uint256"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "symbol",
       "outputs": [{
         "name": "",
         "type": "string"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     },
     {
       "constant": true,
       "inputs": [],
       "name": "totalSupply",
       "outputs": [{
         "name": "",
         "type": "uint256"
       }],
       "payable": false,
       "stateMutability": "view",
       "type": "function"
     }
   ]
   let provider = ethers.getDefaultProvider('rinkeby');
   let contractAddress = contract
   var w = new ethers.Wallet('0x' + privatekey, provider);
   const cc = new ethers.Contract(contractAddress, abi, w);

   let options = {
     gasLimit: 300000,
     gasPrice: ethers.utils.parseUnits('1.0', 'gwei')
   }


   cc.createActivity(title, type, score, metadataURL,metadataHash).then(
     result=> {
       console.log('result->',result)

     }
   )
 }
}

window.addEventListener('load', () => new Main());
