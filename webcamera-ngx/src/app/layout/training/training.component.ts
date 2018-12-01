import { Component, OnInit } from '@angular/core';
import { Subject, Observable } from 'rxjs';

declare var Controller: any;


import { WebcamImage, WebcamInitError, WebcamUtil } from 'ngx-webcam';


@Component({
  selector: 'app-training',
  templateUrl: './training.component.html',
  styleUrls: ['./training.component.scss']
})
export class TrainingComponent implements OnInit {

  public webcamImage: WebcamImage = null;
  private trigger: Subject<void> = new Subject<void>();
  public multipleWebcamsAvailable = false;
  public errors: WebcamInitError[] = [];

  refresh = new Subject()
  run = false

  controller

  
  result_stream = new Subject();

  constructor() { }

  ngOnInit() {

  }
  ngAfterViewInit() {
    this.controller = new Controller()
    this.controller.init(this.result_stream)
  }
  

}
