# ZoomDragView

View that zooms the touched point to enable fine dragging.

### Usage

```
let zoomDragView = ZoomDragView(frame: self.view.bounds)
zoomDragView.image = UIImage(named: "yourImage")
zoomDragView.zoomScale = 4
zoomDragView.touchPointColor = .red // if you want to make the touch point unable, set nil to this value
self.view.addSubview(zoomDragView)
```
