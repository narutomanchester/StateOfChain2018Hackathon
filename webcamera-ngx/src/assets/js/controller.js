
function Controller() {
    let subject;
    let net;

    this.init = async function (sub, msg) {
        subject = sub
        message = msg

        subject.next('hello controller.js')



        //bindPage()
    }
}