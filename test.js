const λ1 = 51.8169 * (Math.PI / 180);
const λ2 = 50.8169 * (Math.PI / 180);
const φ1 = -0.1367 * (Math.PI / 180);
const φ2 = -0.4367 * (Math.PI / 180);
const a = 6378137;
const b = 6356752.314245;
// const f = 1 / 298.257223563;
const f = (a - b) / a;
const L = λ2 - λ1; // L = difference in longitude, U = reduced latitude, defined by tan U = (1-f)·tanφ.
const tanU1 = (1-f) * Math.tan(φ1), cosU1 = 1 / Math.sqrt((1 + tanU1*tanU1)), sinU1 = tanU1 * cosU1;
const tanU2 = (1-f) * Math.tan(φ2), cosU2 = 1 / Math.sqrt((1 + tanU2*tanU2)), sinU2 = tanU2 * cosU2;

let λ = L, sinλ = null, cosλ = null;    // λ = difference in longitude on an auxiliary sphere
let σ = null, sinσ = null, cosσ = null; // σ = angular distance P₁ P₂ on the sphere
let cos2σₘ = null;                      // σₘ = angular distance on the sphere from the equator to the midpoint of the line
let cosSqα = null;                      // α = azimuth of the geodesic at the equator

let λʹ = null;
do {
    console.log(λ);
    sinλ = Math.sin(λ);
    cosλ = Math.cos(λ);
    console.log(sinλ);
    console.log(cosλ);
    console.log((cosU2*sinλ) * (cosU2*sinλ))
    console.log((cosU1*sinU2-sinU1*cosU2*cosλ)**2);
    const sinSqσ = (cosU2*sinλ) * (cosU2*sinλ) + (cosU1*sinU2-sinU1*cosU2*cosλ)**2;
    sinσ = Math.sqrt(sinSqσ);
    cosσ = sinU1*sinU2 + cosU1*cosU2*cosλ;
    σ = Math.atan2(sinσ, cosσ);
    const sinα = cosU1 * cosU2 * sinλ / sinσ;
    cosSqα = 1 - sinα*sinα;
    cos2σₘ = cosσ - 2*sinU1*sinU2/cosSqα;
    const C = f/16*cosSqα*(4+f*(4-3*cosSqα));
    λʹ = λ;
    λ = L + (1-C) * f * sinα * (σ + C*sinσ*(cos2σₘ+C*cosσ*(-1+2*cos2σₘ*cos2σₘ)));
} while (Math.abs(λ-λʹ) > 1e-12);

const uSq = cosSqα * (a*a - b*b) / (b*b);
const A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
const B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
const Δσ = B*sinσ*(cos2σₘ+B/4*(cosσ*(-1+2*cos2σₘ*cos2σₘ)-B/6*cos2σₘ*(-3+4*sinσ*sinσ)*(-3+4*cos2σₘ*cos2σₘ)));

const s = b*A*(σ-Δσ); // s = length of the geodesic

console.log(s);
const α1 = Math.atan2(cosU2*sinλ,  cosU1*sinU2-sinU1*cosU2*cosλ); // initial bearing
const α2 = Math.atan2(cosU1*sinλ, -sinU1*cosU2+cosU1*sinU2*cosλ); // final bearin
console.log(α1)
console.log(α2 * (Math.PI / 180))
