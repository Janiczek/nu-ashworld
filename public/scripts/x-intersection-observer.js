/**
 * Use IntersectionObserver from inside Elm.
 * Handy for the updating table of contents ("which section are you currently reading?").
 *
 * Note that this particular implementation is very much tailored to the above scenario, so it's not fully generic.
 * Tweak the observer callback and options to fit your needs!
 *
 * <x-intersection-observer target-selector=".my-target">
 *   <!-- whatever HTML you put inside -->
 *   <div>
 *     ...
 *     <div class="my-target"> ... </div>
 *     ...
 *   </div>
 * </x-intersection-observer>
 *
 * will send an event "targetintersection" with {detail: {isIntersecting: Boolean, element: Element}} JSON.
 *
 * It can even be the element itself!
 * <x-intersection-observer class="here" target-selector=".here">
 * </x-intersection-observer>
 */
customElements.define(
  "x-intersection-observer",
  class extends HTMLElement {
    static get observedAttributes() {
      return ["target-selector"];
    }

    observedElements = new Set();
    mountTime = Date.now();

    connectedCallback() {
      let lastIntersectionEntry = null;
      let lastScrollY = window.scrollY;
      let scrollingDown = true;

      // Track scroll direction
      document.addEventListener("scroll", () => {
        const currentScrollY = window.scrollY;
        scrollingDown = currentScrollY > lastScrollY;
        lastScrollY = currentScrollY;
      });

      this.intersectionObserver = new IntersectionObserver(
        (entries) => {
          const intersectingEntries = entries
            .filter((e) => e.isIntersecting)
            .sort((a, b) => {
              // Sort by y position to find topmost/bottommost
              const aRect = a.boundingClientRect;
              const bRect = b.boundingClientRect;
              return aRect.top - bRect.top;
            });

          if (intersectingEntries.length === 0) return;

          // Get either topmost or bottommost depending on scroll direction
          const targetEntry = scrollingDown
            ? intersectingEntries[intersectingEntries.length - 1]
            : intersectingEntries[0];

          if (targetEntry.target !== lastIntersectionEntry?.target) {
            const intersectionData = {
              element: targetEntry.target,
              isIntersecting: targetEntry.isIntersecting,
              time: targetEntry.time + this.mountTime,
            };

            lastIntersectionEntry = targetEntry;

            this.dispatchEvent(
              new CustomEvent("targetintersection", {
                detail: intersectionData,
                bubbles: false,
              })
            );
          }
        },
        {
          root: null,
          rootMargin: "0px",
          threshold: 0,
        }
      );

      const elements = this.querySelectorAll(
        this.getAttribute("target-selector")
      );
      for (const element of elements) {
        this.observedElements.add(element);
        this.intersectionObserver.observe(element);
      }
    }

    disconnectedCallback() {
      for (const element of this.observedElements) {
        this.intersectionObserver.unobserve(element);
      }
      this.observedElements.clear();
    }

    attributeChangedCallback(attrName, _, newValue) {
      if (attrName === "target-selector" && newValue) {
        // Unobserve old elements
        for (const element of this.observedElements) {
          this.intersectionObserver.unobserve(element);
        }
        this.observedElements.clear();

        // Observe new elements
        const newElements = this.querySelectorAll(newValue);
        if (this.intersectionObserver) {
          for (const element of newElements) {
            this.observedElements.add(element);
            this.intersectionObserver.observe(element);
          }
        }
      }
    }
  }
);
