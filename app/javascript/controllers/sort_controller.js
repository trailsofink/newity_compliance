import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["list", "label"];

    connect() {
        this.ascending = true; // Start newest first
        this.sort();
    }

    toggle() {
        this.ascending = !this.ascending;
        this.labelTarget.textContent = this.ascending
            ? "Newest First"
            : "Oldest First";
        this.sort();
    }

    sort() {
        if (!this.hasListTarget) return;

        const items = Array.from(
            this.listTarget.querySelectorAll(".comment-item"),
        );
        if (items.length === 0) return;

        items.sort((a, b) => {
            const dateA = parseInt(a.dataset.date, 10);
            const dateB = parseInt(b.dataset.date, 10);

            return this.ascending ? dateB - dateA : dateA - dateB;
        });

        items.forEach((item) => this.listTarget.appendChild(item));
    }
}
