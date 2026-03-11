# Domain Boundaries

> **CRITICAL FILE FOR AUTONOMOUS AGENT.**
> The triage agent reads this file to decide whether a JIRA/Linear issue belongs to this
> project. Be specific and concrete — vague boundaries cause wrong accept/reject decisions.
> Update this file whenever the project scope changes.

---

## Project Domain Statement

**One-sentence description the agent uses as primary filter:**

> TODO: e.g., "This project manages the full lifecycle of e-commerce orders — from cart
> checkout through payment, fulfilment, and returns — for B2C merchants."

---

## What This Project IS Responsible For

List the specific functional areas, features, and system boundaries that ARE in scope.
The more concrete, the better. Include examples of typical requests.

### Core Domains
- TODO: e.g., **Order Management** — creating, updating, cancelling, and querying orders
- TODO: e.g., **Payment Processing** — charging, refunding, and reconciling payments
- TODO: e.g., **Inventory Tracking** — stock levels, reservations, reorder triggers

### APIs & Interfaces Owned by This Project
- TODO: e.g., `POST /v1/orders`, `GET /v1/orders/{id}`, `POST /v1/payments`
- TODO: e.g., Internal event: `OrderPlaced`, `PaymentFailed`, `StockDepleted`

### Databases / Data Owned by This Project
- TODO: e.g., `orders` table, `order_items` table, `payment_transactions` table

### Typical In-Scope Request Examples
```
✅ "Add discount code support to checkout"
✅ "Fix order status not updating after payment"
✅ "Add pagination to the order history API"
✅ "Migrate payment provider from Stripe to Adyen"
✅ "Add retry logic when payment webhook times out"
```

---

## What This Project Is NOT Responsible For

Explicitly list areas, systems, and teams that are out of scope.
This is as important as the in-scope list — the agent uses this to reject irrelevant issues.

### Out-of-Scope Domains
- TODO: e.g., **User Authentication** — owned by the Auth service team
- TODO: e.g., **Product Catalog** — owned by the Catalog service
- TODO: e.g., **Shipping Logistics** — integration only; the Shipping service owns the domain
- TODO: e.g., **Marketing / CMS** — separate system, separate team

### Systems This Project Integrates With (but does not own)
- TODO: e.g., Stripe API — we call it but do not own it
- TODO: e.g., SendGrid — email delivery; we trigger but do not own
- TODO: e.g., Warehouse Management System (WMS) — we emit events; WMS owns fulfilment

### Typical Out-of-Scope Request Examples
```
❌ "Update the product description on the listing page"  → Catalog team
❌ "Add SSO login for internal employees"               → Auth/Identity team
❌ "Redesign the marketing landing page"               → Marketing team
❌ "Add tracking number to shipment label"             → Shipping service
❌ "Upgrade the Kubernetes cluster node size"          → Platform/Infra team
```

---

## Ambiguous / Boundary Cases

These are cases that could go either way. Define how the agent should handle them.

| Scenario | Decision | Reason |
|----------|----------|--------|
| TODO: e.g., Adding a new payment method | ACCEPT | Core payment domain |
| TODO: e.g., Changing the checkout UI | ESCALATE | Unclear if this is frontend or backend scope |
| TODO: e.g., Reporting / analytics on orders | ESCALATE | May belong to a dedicated analytics service |
| TODO: e.g., Infrastructure/DevOps tasks | REJECT unless tied to this service | Platform team owns infra |

**Rule for ambiguous cases:** If the issue directly changes code in this repository, ACCEPT.
If it only requires changes in another system we call, REJECT and add a comment to the ticket.

---

## Agent Classification Guidance

The triage agent uses this section to produce a structured decision:

### Confidence Scoring Guide
| Confidence | Meaning | Agent Action |
|------------|---------|-------------|
| 0.90–1.00 | Clearly in domain | Auto-accept |
| 0.80–0.89 | Probably in domain | Auto-accept with note |
| 0.50–0.79 | Uncertain | Escalate to human |
| 0.30–0.49 | Probably out of domain | Escalate to human |
| 0.00–0.29 | Clearly out of domain | Auto-reject, add comment to ticket |

### Keywords That Increase Domain Confidence
```
TODO: Fill in domain-specific keywords that signal in-scope work.
Example: order, payment, cart, checkout, refund, inventory, fulfilment, merchant
```

### Keywords That Decrease Domain Confidence
```
TODO: Fill in keywords that signal out-of-scope work.
Example: authentication, SSO, login, marketing, analytics, infrastructure, k8s, helm
```

### Entities That Belong to This Domain
```
TODO: List the core entities that this project manages.
Example: Order, OrderItem, Payment, Refund, StockLevel, Merchant, Cart, Coupon
```

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| TODO | Initial version | Project kickoff |

*Update this table whenever the domain scope changes. The agent checks the last-updated date
and warns if this file has not been reviewed in more than 30 days.*

**Last reviewed:** TODO: YYYY-MM-DD
**Reviewed by:** TODO
