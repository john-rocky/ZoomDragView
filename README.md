# ZoomDragView

View that zooms the touched point to enable fine dragging.

![Jun-14-2023 12-46-29](https://github.com/john-rocky/PersonSegmentationSampler/assets/23278992/0e098ed7-54b6-45b6-96a4-f28b87f661b0)

### Usage

```
let zoomDragView = ZoomDragView(frame: self.view.bounds)
zoomDragView.image = UIImage(named: "yourImage")
zoomDragView.zoomScale = 4
zoomDragView.touchPointColor = .red // if you want to make the touch point unable, set nil to this value
self.view.addSubview(zoomDragView)
```
