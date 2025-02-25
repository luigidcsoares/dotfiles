(setq package-enable-at-startup nil)

(tooltip-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tab-bar-mode t)

(push '(fullscreen . maximized) default-frame-alist)
(push '(undecorated . t) default-frame-alist)
