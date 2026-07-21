enum InterviewRoutes {
  home('/'),
  timer('/timer'),
  router('/router'),
  state('/state'),
  di('/di'),
  http('/http'),
  painter('/painter'),
  animation('/animation'),
  storage('/storage'),
  eventQueue('/event-queue'),
  repaintBoundary('/repaint-boundary'),
  goodsDetail('/goods/detail'),
  orderDetail('/order/detail');

  final String path;
  const InterviewRoutes(this.path);
}
