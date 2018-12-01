function HashAds() {

    let subject;
    let net;

    const videoWidth = 640;
    const videoHeight = 480;


    /*
    this.init = async function (sub,msg) {
        subject = sub
        message = msg
        
            subject.next('hello hashads.js')
       


        bindPage()
    }
    */
    let callback
    let frameCount = 0
    this.init = async function (cb) {

        callback = cb;

        bindPage()
    }


    async function setupCamera() {


        const video = document.getElementById('video');
        video.width = videoWidth;
        video.height = videoHeight;


        const stream = await navigator.mediaDevices.getUserMedia({
            'audio': false,
            'video': {
                facingMode: 'user',
                width: videoWidth,
                height: videoHeight,
            },
        });
        video.srcObject = stream;

        return new Promise((resolve) => {
            video.onloadedmetadata = () => {
                resolve(video);
            };
        });
    }



    async function bindPage() {
        // Load the PoseNet model weights with architecture 0.75
        const net = await posenet.load(0.75);

        let video;

        try {
            video = await loadVideo();
        } catch (e) {
            console.error(e)
        }

        //setupGui([], net);
        //setupFPS();

        detectPoseInRealTime(video, net);
    }

    async function loadVideo() {
        const video = await setupCamera();
        video.play();

        return video;
    }

    function detectPoseInRealTime(video, net) {

        try {
            const canvas = document.getElementById('output');
            const ctx = canvas.getContext('2d');
            canvas.width = videoWidth;
            canvas.height = videoHeight;

        } catch (e) {

        }

        // since images are being fed from a webcam
        const flipHorizontal = true;



        this.poseDetectionFrame = async () => {




            // Scale an image down to a certain factor. Too large of an image will slow
            // down the GPU
            const imageScaleFactor = 0.5;
            const outputStride = 16;

            let poses = [];
            let minPoseConfidence;
            let minPartConfidence;

            const algorithm = 'multi-pose'


            switch (algorithm) {
                case 'single-pose':
                    const pose = await guiState.net.estimateSinglePose(
                        video, imageScaleFactor, flipHorizontal, outputStride);
                    poses.push(pose);
                    minPoseConfidence = 0.1;
                    minPartConfidence = 0.5;

                    break;
                case 'multi-pose':
                    /*
                    poses = await guiState.net.estimateMultiplePoses(
                        video, imageScaleFactor, flipHorizontal, outputStride,
                        guiState.multiPoseDetection.maxPoseDetections,
                        guiState.multiPoseDetection.minPartConfidence,
                        guiState.multiPoseDetection.nmsRadius);
                    */
                    minPoseConfidence = 0.1;
                    minPartConfidence = 0.5;
                    poses = await net.estimateMultiplePoses(
                        video, imageScaleFactor, flipHorizontal, outputStride);
                    break;
            }

            //ctx.clearRect(0, 0, videoWidth, videoHeight);
            // display video

            if (false) {
                ctx.save();
                ctx.scale(-1, 1);
                ctx.translate(-videoWidth, 0);
                ctx.drawImage(video, 0, 0, videoWidth, videoHeight);
                ctx.restore();
            }


            // For each pose (i.e. person) detected in an image, loop through the poses
            // and draw the resulting skeleton and keypoints if over certain confidence
            // scores
            let personCount = 1
            poses.forEach(({
                score,
                keypoints
            }) => {

                let kps = []
                for (let ks of keypoints) {
                    if (ks.part.includes('Eye') || ks.part.includes('Ear') || ks.part.includes('nose')) {
                        kps.push(ks)
                    }
                }



                if (score >= minPoseConfidence) {
                    if (true) {
                        //drawKeypoints(kps, minPartConfidence, ctx);
                    }
                    if (false) {
                        //drawSkeleton(kps, minPartConfidence, ctx);
                    }
                    if (false) {
                        drawBoundingBox(kps, ctx);
                    }
                    const result = {
                        person: personCount,
                        keypoints: kps
                    }
                    //subject.next(result)
                    if (frameCount % 10 == 0) {
                        callback.callback(result)
                    }


                    personCount += 1
                }
            });

            frameCount += 1
            if (frameCount % 10 == 0) {
                frameCount = 0
            }



            requestAnimationFrame(poseDetectionFrame);
        }

        poseDetectionFrame();
    }






}
