var animation_number = 0;
var animations = [];

function key_event(type, event) {
    console.log('Handler for ' + type + ' called. - ' + event.keyCode);
    var code = event.keyCode;
    if (code == 8 || code == 37) {
        event.preventDefault();
        previous_step();
    }
    else if (code == 32 || code == 39) {
        event.preventDefault();
        next_step();
    }
    else if (code == 33) {
        event.preventDefault();
        if (window.event.shiftKey)
            previous_page();
        else
            previous_step();
    }
    else if (code == 34) {
        event.preventDefault();
        if (window.event.shiftKey)
            goto_next_page();
        else
            next_step();
    }
    else if (code == 38) {
        event.preventDefault();
        goto_index();
    }
}

function register_animation(id, num, type, param) {
    if (!animations[num-1]) {
        animations[num-1] = [];
    }
    animations[num-1].push({ "type" : type, "id" : id });
    var elem = $('#' + id);
    if (type == 'appear') {
        elem.hide();
    }
    else if (type == 'flyin') {
        elem.hide();
    }
    else if (type == 'greyin') {
        elem.css('color', '#ddd');
    }
}
function previous_step() {
    if (animation_number > 0) {
        location.reload();
    }
    else {
        previous_page();
    }
}
function next_step() {
    if (animation_number < animations.length) {
        next_animation();
        return;
    }
    console.log(animation_number);
    goto_next_page();
}
function goto_next_page() {
    location.href = next_page;
}
function previous_page() {
    location.href = prev_page;
}
function goto_index() {
    location.href = 'index.html';
}
function next_animation() {
    var anis = animations[animation_number];
    animation_number++;
    if (! anis) {
        next_step();
        return;
    }
    console.log('next_animation()');
    $(anis).each(function(i, ani) {
        var type = ani["type"];
        var id = ani["id"];
        console.log('id: ' + id);
        console.log('type: ' + type);
        var elem = $('#' + id);
        if (type == 'appear') {
            elem.hide();
            elem.fadeIn(400);
        }
        else if (type == 'flyin') {
            var currWidth = $(window).width();
            var margin = elem.css('margin-left');
            elem.css('margin-left', currWidth + 'px');
            elem.show();
            elem.animate({"margin-left": margin}, 400);
        }
        else if (type == 'greyin') {
            elem.css('color', 'black');
        }
        else if (type == 'strike') {
            elem.css('text-decoration', 'line-through');
            elem.css('color', 'red');
        }
    });
}

