var components = [];

function addComponent(component, file) {
    components.push({ component : component, file: file})
}


function findReadyComponent()
{
    for ( var i=0; i<components.length; i++)
    {
        var o = components[i];
        var c = o.component;
        if ( c.status == Component.Ready)
        {
            components.splice(i, 1);
            return o;
        }
    }

    return null;
}
