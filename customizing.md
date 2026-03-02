# Customizing the Kiosk for Other Stops

This project is configured for a specific stop in Lafayette, but it can be easily adapted for any route within the Lafayette Transit System (LTS).

## 1️⃣ Finding Route and Stop IDs
The URLs used in this project contain specific identifiers for the route, direction, and stop. To find IDs for a different location:

1. Visit the mobile page here: https://lts.syncromatics.com/m/
2. Select your **Route**.
3. Then choose your **Stop**.
4. Once the arrival times load, look at the URL in your browser's address bar.
5. Identify the ID numbers in the URL structure: https://lts.syncromatics.com/m/routes/2050/direction/25790/stops/1633019/pattern
   `.../m/routes/[ROUTE_ID]/direction/[DIRECTION_ID]/stops/[STOP_ID]/pattern`

## 2️⃣ Updating Data Sources
Open `index.html` and locate the `const` definitions in the `<script>` section. Replace the existing URLs with the ones you found in the previous step:

* **ARRIVALS_URL**: Use the mobile pattern URL (ends in `/pattern`).
* **MAP_URL**: Use the mobile map URL (ends in `/map`).

## 3️⃣ Adjusting Visual Labels
To ensure the kiosk displays the correct information to the public, update the following HTML elements in `index.html`:

* **Header Title**: Change `<h1>Lafayette Transit Live Arrivals</h1>` if needed.
* **Stop Description**: Update the `<div class="stop">` text to reflect the new street names and Stop #.
