strap-lie
=========

Give your non-admin user delusions of grandeur.

---

This repository is single shell script that puts a few aliases in place such
that [strap][strap] will believe that your user can `sudo` when really it's
a different admin user that's doing it.

Using the UMass convention by default, it will first check if a user named
"youruser-d" exists. If not, then it will ask you for a different user. The
falsehoods will only be put in place if that user _can_, in fact, use `sudo`.

[strap]: https://github.com/umts/strap/
