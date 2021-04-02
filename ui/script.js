$(function(){
    window.addEventListener("message", function(event){
        var a = `Route:  `
        var position = 7;
        if (event.data.show == true) {
            $(".text").hide(2000)
        }
        if (event.data.show == false) {
            var selector = document.querySelector(".text")
            selector.style = "display:block;"
        }  
        
        $(".route").html(event.data.route);

        
    })

})

document.addEventListener("DOMContentLoaded", () => {
    $(".text").hide();
});
