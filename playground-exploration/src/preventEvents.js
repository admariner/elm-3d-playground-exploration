export { preventEvents };

const preventEvents = () => {
  prevent("pointerdown");
  prevent("wheel");
};

const prevent = (eventType) => {
  document.addEventListener(
    eventType,
    function (e) {
      if (e.target && document.querySelector("#gui")?.contains(e.target)) {
        e.stopPropagation();
      }
    },
    true
  );
};
