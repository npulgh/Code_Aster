subroutine xxnmgr(elrefp, elrese, ndim, coorse, igeom,&
                  he, nfh, ddlc, ddlm, nfe,&
                  instam, instap, ideplp, sigm, vip,&
                  basloc, nnop, npg, typmod, option,&
                  imate, compor, lgpg, idecpg, crit,&
                  idepl, lsn, lst, nfiss, heavn,&
                  sigp, vi, matuu, ivectu, codret, jstno)
!
! aslint: disable=W1306,W1504
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/dfdm2d.h"
#include "asterfort/dfdm3d.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/indent.h"
#include "asterfort/lcegeo.h"
#include "asterfort/matinv.h"
#include "asterfort/nmcomp.h"
#include "asterfort/r8inir.h"
#include "asterfort/reeref.h"
#include "asterfort/utmess.h"
#include "asterfort/vecini.h"
#include "asterfort/xcinem.h"
#include "asterfort/xcalc_code.h"
#include "asterfort/xcalc_heav.h"
#include "asterfort/xcalfev_wrap.h"
#include "asterfort/xkamat.h"
#include "asterfort/iimatu.h"
#include "asterfort/iipff.h"
#include "asterfort/xnbddl.h"
    integer :: ndim, igeom, imate, lgpg, codret, nnop, npg
    integer :: nfiss, heavn(nnop, 5), idecpg
    integer :: nfh, ddlc, ddlm, nfe
    integer :: jstno
    character(len=8) :: elrefp, typmod(*), elrese
    character(len=16) :: option, compor(4)
    real(kind=8) :: basloc(3*ndim*nnop), crit(3), he(nfiss)
    integer :: idepl, ideplp, ivectu
    real(kind=8) :: lsn(nnop), lst(nnop), coorse(*)
    real(kind=8) :: vi(lgpg, npg), vip(lgpg, npg), sigp(2*ndim, npg), matuu(*)
    real(kind=8) :: instam, instap, sigm(2*ndim, npg), sign(6)
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: patrick.massin at edf.fr
!
!.......................................................................
!
!     BUT:  CALCUL  DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
!           EN GRANDE ROTATION ET PETITE DEFORMATION AVEC X-FEM EN 2D
!
!     TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
!.......................................................................
!
! IN  ELREFP  : ÉLÉMENT DE RÉFÉRENCE PARENT
! IN  NDIM    : DIMENSION DE L'ESPACE
! IN  COORSE  : COORDONNÉES DES SOMMETS DU SOUS-ÉLÉMENT
! IN  IGEOM   : COORDONNÉES DES NOEUDS DE L'ÉLÉMENT PARENT
! IN  HE      : VALEUR DE LA FONCTION HEAVISIDE SUR LE SOUS-ÉLT
! IN  NFH     : NOMBRE DE DDL HEAVYSIDE (PAR NOEUD)
! IN  DDLC    : NOMBRE DE DDL DE CONTACT (PAR NOEUD)
! IN  DDLM    : NOMBRE DE DDL PAR NOEUD MILIEU (EN 2D)
! IN  NFE     : NOMBRE DE FONCTIONS SINGULIÈRES D'ENRICHISSEMENT
! IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE AUX NOEUDS
! IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
! IN  NPG     : NOMBRE DE POINTS DE GAUSS DU SOUS-ÉLÉMENT
! IN  TYPMOD  : TYPE DE MODELISATION
! IN  OPTION  : OPTION DE CALCUL
! IN  IMATE   : MATERIAU CODE
! IN  COMPOR  : COMPORTEMENT
! IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
!               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
! IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
! IN  IDEPL   : ADRESSE DU DEPLACEMENT A PARTIR DE LA CONF DE REF
! IN  LSN     : VALEUR DE LA LEVEL SET NORMALE AUX NOEUDS PARENTS
! IN  LST     : VALEUR DE LA LEVEL SET TANGENTE AUX NOEUDS PARENTS
!
! OUT SIGP    : CONTRAINTES DE CAUCHY (RAPH_MECA ET FULL_MECA)
! OUT VI      : VARIABLES INTERNES    (RAPH_MECA ET FULL_MECA)
! OUT MATUU   : MATRICE DE RIGIDITE PROFIL (RIGI_MECA_TANG ET FULL_MECA)
! OUT VECTU   : FORCES NODALES (RAPH_MECA ET FULL_MECA)
!......................................................................
!
    integer :: i, ig, j, j1, k, kk, kkd, kpg, l, m, mn, n, nn
    integer :: ddls, ddld, ddldn, cpt, dec(nnop), hea_se
    integer :: idfde, ipoids, ivf, jcoopg, jdfd2, jgano
    integer :: ndimb, nno, nnops, nnos, npgbis
    integer :: singu, alp, ii, jj
    real(kind=8) :: f(3, 3), fm(3, 3), fr(3, 3), epsm(6), epsp(6), deps(6)
    real(kind=8) :: dsidep(6, 6), sigma(6), ftf, detf
    real(kind=8) :: tmp1, tmp2, sig(6)
    real(kind=8) :: xg(ndim), xe(ndim), ff(nnop), jac
    real(kind=8) :: rbid33(3, 3), rbid1(1)
    real(kind=8) :: dfdi(nnop, ndim), pff(1+nfh+nfe*ndim**2, nnop, ndim)
    real(kind=8) :: def(6, nnop, ndim*(1+nfh+nfe*ndim))
    real(kind=8) :: elgeom(10, 27), dfdib(27, 3)
    real(kind=8) :: fmm(3, 3), deplb1(3, 27), deplb2(3, 27)
    real(kind=8) :: fk(27,3,3), dkdgl(27,3,3,3), ka, mu
    aster_logical :: grdepl, axi, cplan, resi, rigi
!
    integer :: indi(6), indj(6)
    real(kind=8) :: rind(6), rind1(6), rac2, angmas(3)
    data    indi / 1 , 2 , 3 , 1 , 1 , 2 /
    data    indj / 1 , 2 , 3 , 2 , 3 , 3 /
    data    rind / 0.5d0,0.5d0,0.5d0,0.70710678118655d0,&
     &               0.70710678118655d0,0.70710678118655d0 /
    data    rac2 / 1.4142135623731d0 /
    data    angmas /0.d0, 0.d0, 0.d0/
    data    rind1 / 0.5d0 , 0.5d0 , 0.5d0 , 1.d0, 1.d0, 1.d0 /
!--------------------------------------------------------------------
!
!
!     NOMBRE DE DDL DE DEPLACEMENT À CHAQUE NOEUD
    call xnbddl(ndim, nfh, nfe, ddlc, ddld, ddls, singu)
    ddldn = 1+nfh+nfe*ndim**2
!
!     RECUPERATION DU NOMBRE DE NOEUDS SOMMETS DE L'ELEMENT PARENT
    call elrefe_info(fami='RIGI', nnos=nnops)
!
! - INITIALISATION
    grdepl = compor(3) .eq. 'GROT_GDEP'
    axi = typmod(1) .eq. 'AXIS'
    cplan = typmod(1) .eq. 'C_PLAN'
    resi = option(1:4).eq.'RAPH' .or. option(1:4).eq.'FULL'
    rigi = option(1:4).eq.'RIGI' .or. option(1:4).eq.'FULL'
!
    if (axi) then
        call utmess('F', 'XFEM2_5')
    endif
!
    call elrefe_info(elrefe=elrese, fami='XINT', ndim=ndimb, nno=nno, nnos=nnos,&
                     npg=npgbis, jpoids=ipoids, jcoopg=jcoopg, jvf=ivf, jdfde=idfde,&
                     jdfd2=jdfd2, jgano=jgano)
!
    ASSERT(npg.eq.npgbis.and.ndim.eq.ndimb)
!
! - CALCUL DES ELEMENTS GEOMETRIQUES SPECIFIQUES LOIS DE COMPORTEMENT
! - LES ARGUMENTS DFDIB, DEPLB1, DEPLB2 NE SERVENT PAS DANS CE CAS
    call lcegeo(nno, npg, ipoids, ivf, idfde,&
                zr(igeom), typmod, compor, ndim, dfdib,&
                deplb1, deplb2, elgeom)
!
    do n = 1, nnop
        call indent(n, ddls, ddlm, nnops, dec(n))
    end do
!
! CALCUL DE L IDENTIFIANT DU SS ELEMENT
    hea_se=xcalc_code(nfiss, he_real=[he])
!-----------------------------------------------------------------------
! - CALCUL POUR CHAQUE POINT DE GAUSS DU SOUS-ELEMENT
    do kpg = 1, npg
!
!       COORDONNÉES DU PT DE GAUSS DANS LE REPÈRE RÉEL : XG
        call vecini(ndim, 0.d0, xg)
        do i = 1, ndim
            do n = 1, nno
                xg(i) = xg(i) + zr(ivf-1+nno*(kpg-1)+n)*coorse(ndim*( n-1)+i)
            end do
        end do
!
!       COORDONNÉES DU POINT DE GAUSS DANS L'ÉLÉMENT DE RÉF PARENT : XE
!       ET CALCUL DE FF, DFDI, EPSM ET EPSP
!       CALCUL EN T-
        call reeref(elrefp, nnop, zr(igeom), xg, ndim,&
                    xe, ff, dfdi=dfdi)
!
!       FONCTION D'ENRICHISSEMENT AU POINT DE GAUSS ET LEURS DÉRIVÉES
        if (singu .gt. 0) then
            call xkamat(imate, ndim, axi, ka, mu)
            call xcalfev_wrap(ndim, nnop, basloc, zi(jstno), he(1),&
                         lsn, lst, zr(igeom), ka, mu, ff, fk, dfdi, dkdgl)
        endif
!
        call xcinem(axi, igeom, nnop, nnops, idepl, grdepl,&
                    ndim, he,&
                    nfiss, nfh, singu, ddls, ddlm,&
                    fk, dkdgl, ff, dfdi, fm,&
                    epsm, rbid33, heavn)
!
!       CALCUL EN T+
        call xcinem(axi, igeom, nnop, nnops, ideplp, grdepl,&
                    ndim, he,&
                    nfiss, nfh, singu, ddls, ddlm,&
                    fk, dkdgl, ff, dfdi, f,&
                    epsp, rbid33, heavn)
!
!       CALCUL DE DEPS POUR LDC
        do i = 1, 6
            deps(i) = epsp(i)-epsm(i)
        end do
!
!      CALCUL DES PRODUITS SYMETR. DE F PAR N,
        if (resi) then
            do i = 1, 3
                do j = 1, 3
                    fr(i,j) = f(i,j)
                end do
            end do
        else
            do i = 1, 3
                do j = 1, 3
                    fr(i,j) = fm(i,j)
                end do
            end do
        endif
!
!
!       CALCUL DES PRODUITS SYMETR. DE F PAR N,
        def(:,:,:)=0.d0
        do n = 1, nnop
!         FONCTIONS DE FORME CLASSIQUES
            do i = 1, ndim
                def(1,n,i) = fr(i,1)*dfdi(n,1)
                def(2,n,i) = fr(i,2)*dfdi(n,2)
                def(3,n,i) = 0.d0
                def(4,n,i) = (fr(i,1)*dfdi(n,2) + fr(i,2)*dfdi(n,1))/ rac2
                if (ndim .eq. 3) then
                    def(3,n,i) = fr(i,3)*dfdi(n,3)
                    def(5,n,i) = (fr(i,1)*dfdi(n,3) + fr(i,3)*dfdi(n, 1))/rac2
                    def(6,n,i) = (fr(i,2)*dfdi(n,3) + fr(i,3)*dfdi(n, 2))/rac2
                endif
            end do
!         ENRICHISSEMENT PAR HEAVYSIDE
            do ig = 1, nfh
                do i = 1, ndim
                    cpt = ndim*(1+ig-1)+i
                    do m = 1, 2*ndim
                        def(m,n,cpt) = def(m,n,i) * xcalc_heav(heavn(n,ig),hea_se,heavn(n,5))
                    end do
                    if (ndim .eq. 2) def(3,n,cpt) = 0.d0
                end do
            end do
!         ENRICHISSEMENT PAR LES NFE FONTIONS SINGULIÈRES
            do ig = 1, singu
              do alp = 1, ndim
                do i = 1, ndim
                    cpt = cpt+1
                    def(1,n,cpt) = fr(i,1)* dkdgl(n,alp,i,1)
!
                    def(2,n,cpt) = fr(i,2)* dkdgl(n,alp,i,2)
!
                    def(3,n,cpt) = 0.d0
!
                    def(4,n,cpt) = (&
                                   fr(i,1)* dkdgl(n,alp,i,2) + fr(i,2)* dkdgl(n,alp,i,1)&
                                   )/rac2
!
                    if (ndim .eq. 3) then
                        def(3,n,cpt) = fr(i,3)* dkdgl(n,alp,i,3)
                        def(5,n,cpt) = (&
                                       fr(i,1)* dkdgl(n,alp,i,3) + fr(i,3)* dkdgl(n,alp,i,1)&
                                       )/rac2
                        def(6,n,cpt) = (&
                                       fr(i,3)* dkdgl(n,alp,i,2) + fr(i,2)* dkdgl(n,alp,i,3)&
                                       )/rac2
                    endif
                enddo
              enddo
            enddo
            ASSERT(cpt.eq.ddld)
!
        end do
!
!       POUR CALCULER LE JACOBIEN DE LA TRANSFO SSTET->SSTET REF
!       ON ENVOIE DFDM2D OU DFDM3D AVEC LES COORD DU SS-ELT
        if (ndim .eq. 2) then
            call dfdm2d(nno, kpg, ipoids, idfde, coorse,&
                        jac)
        else if (ndim.eq.3) then
            call dfdm3d(nno, kpg, ipoids, idfde, coorse,&
                        jac)
        endif
!
!      CALCUL DES PRODUITS DE FONCTIONS DE FORMES (ET DERIVEES)
        if (rigi) then
            do i = 1, ndim
                do n = 1, nnop
                    cpt = 1
                    pff(cpt,n,i) = dfdi(n,i)
                    do ig = 1, nfh
                        cpt = cpt+1
                        pff(cpt,n,i) = dfdi(n,i) * xcalc_heav(heavn(n,ig),hea_se,heavn(n,5))
                    end do
                    do alp = 1, ndim*nfe
                        do k = 1, ndim
                          cpt = cpt+1
                          pff(cpt,n,i) = dkdgl(n,alp,k,i)
                        end do
                    end do
                    ASSERT(cpt.eq.ddldn)
                end do
            end do
        endif
!
!       LOI DE COMPORTEMENT
!       CONTRAINTE CAUCHY -> CONTRAINTE LAGRANGE POUR LDC EN T-
        if (cplan) fm(3,3) = sqrt(abs(2.d0*epsm(3)+1.d0))
        call matinv('S', 3, fm, fmm, detf)
        call vecini(6, 0.d0, sign)
        do i = 1, 2*ndim
            do l = 1, 2*ndim
                ftf = (&
                      fmm(&
                      indi(i), indi(l)) * fmm(indj(i), indj(l)) + fmm(indi(i),&
                      indj(l)) * fmm(indj(i), indi(l))&
                      ) * rind1(l&
                      )
                sign(i) = sign(i) + ftf * sigm(l,kpg)
            end do
            sign(i) = sign(i) * detf
        end do
        if (ndim .eq. 2) sign(4) = sign(4) * rac2
        if (ndim .eq. 3) then
            do m = 4, 2*ndim
                sign(m) = sigm(m,kpg) * rac2
            end do
        endif
!
!
!       INTEGRATION
!
        call r8inir(6, 0.0d0, sigma, 1)
        call nmcomp('XFEM', idecpg+kpg, 1, ndim, typmod,&
                    imate, compor, crit, instam, instap,&
                    6, epsm, deps, 6, sign,&
                    vi(1, kpg), option, angmas, 10, elgeom(1, kpg),&
                    sigma, vip(1, kpg), 36, dsidep, 1,&
                    rbid1, codret)
!
! - CALCUL DE LA MATRICE DE RIGIDITE
        if (rigi) then
!
!          RIGIDITÉ GEOMETRIQUE
            do n = 1, nnop
                nn=dec(n)
!
                do m = 1, n
                    mn=dec(m)
!
                    do i = 1, ddldn
                        do j = 1, ddldn
                            tmp1 = 0.d0
                            if (option(1:4) .eq. 'RIGI') then
                                tmp1 = sign(1)*pff(i,n,1)*pff(j,m,1) + sign(2)*pff(i,n,2)*pff(j,m&
                                       &,2) + sign(4)*(pff(i,n,1)*pff(j,m,2) +pff(i,n,2)*pff(j,m,&
                                       &1))/rac2
                                if (ndim .eq. 3) then
                                    tmp1 = tmp1 + sign(3)*pff(i,n,3)* pff(j,m,3) + sign(5)*(pff(i&
                                           &,n,1)* pff(j,m,3) +pff(i,n,3)*pff(j,m,1)) /rac2 + sig&
                                           &n(6)*(pff(i,n,3)*pff(j, m,2) +pff(i,n,2)*pff(j,m,3))/&
                                           &rac2
                                endif
                            else
                                tmp1 = sigma(1)*pff(i,n,1)*pff(j,m,1) + sigma(2)*pff(i,n,2)*pff(j&
                                       &,m,2) + sigma(4)*(pff(i,n,1)*pff(j,m,2) +pff(i,n,2)*pff(j&
                                       &,m,1))/rac2
                                if (ndim .eq. 3) then
                                    tmp1 = tmp1 + sigma(3)*pff(i,n,3)* pff(j,m,3) + sigma(5)*(pff&
                                           &(i,n,1)* pff(j,m,3) +pff(i,n,3)*pff(j,m,1)) /rac2 + s&
                                           &igma(6)*(pff(i,n,3)*pff( j,m,2) +pff(i,n,2)*pff(j,m,3&
                                           &))/ rac2
                                endif
                            endif
!                 STOCKAGE EN TENANT COMPTE DE LA SYMETRIE
                            if (m .eq. n) then
                                j1 = iipff(i,ndim,nfh,nfe)
                            else
                                j1 = ddldn
                            endif
                            if (iipff(j,ndim,nfh,nfe) .le. j1) then
                                do l = 1, ndim
                                    ii=iimatu((iipff(i,ndim,nfh,nfe)-1)*ndim+l,ndim,nfh,nfe)
                                    kkd = ( nn+ii-1) * (nn+ii ) /2
!
                                    jj=iimatu((iipff(j,ndim,nfh,nfe)-1)*ndim+l,ndim,nfh,nfe)
                                    kk = kkd + mn+jj
!
                                    matuu(kk) = matuu(kk) + tmp1*jac
                                end do
                            endif
                        end do
                    end do
                end do
            end do
!         RIGIDITE ELASTIQUE
            do n = 1, nnop
                nn=dec(n)
!
                do i = 1, ddld
                    ii=iimatu(i,ndim,nfh,nfe)
                    do l = 1, 2*ndim
                        sig(l) = 0.d0
                        do k = 1, 2*ndim
                            sig(l) = sig(l) + def(k,n,i) * dsidep(k,l)
                        end do
                    end do
                    do j = 1, ddld
                        jj=iimatu(j,ndim,nfh,nfe)
                        do m = 1, n
                            tmp2 = 0.d0
                            mn=dec(m)
                            do k = 1, 2*ndim
                                tmp2 = tmp2 + sig(k) * def(k,m,j)
                            end do
!
!                STOCKAGE EN TENANT COMPTE DE LA SYMETRIE
                            if (m .eq. n) then
                                j1 = ii
                            else
                                j1 = ddld
                            endif
                            if (jj .le. j1) then
                                kkd = (nn+ii-1) * (nn+ii) /2
                                matuu(kkd+mn+jj) = matuu(kkd+mn+jj) + tmp2*jac
                            endif
                        end do
                    end do
                end do
            end do
        endif
!
! - CALCUL DE LA FORCE INTERIEURE
!
        if (resi) then
!
            do n = 1, nnop
                nn=dec(n)
                do i = 1, ddld
                    ii=iimatu(i,ndim,nfh,nfe)
                    do l = 1, 2*ndim
                        zr(ivectu-1+nn+ii)= zr(ivectu-1+nn+ii) + def(l,&
                        n,i)*sigma(l)*jac
                    end do
                end do
            end do
!
!    CALCUL DES CONTRAINTES DE CAUCHY, CONVERSION LAGRANGE -> CAUCHY
!
            if (cplan) f(3,3) = sqrt(abs(2.d0*epsp(3)+1.d0))
            detf = f(3,3) * (f(1,1)*f(2,2)-f(1,2)*f(2,1))
            if (ndim .eq. 3) then
                detf = detf - f(2,3)*(f(1,1)*f(3,2)-f(3,1)*f(1,2)) + f(1,3)*(f(2,1)*f(3,2)-f(3,1)&
                       &*f(2,2))
            endif
            do i = 1, 2*ndim
                sigp(i,kpg) = 0.d0
                do l = 1, 2*ndim
                    ftf = (&
                          f(&
                          indi(i), indi(l))*f(indj(i), indj(l)) + f(indi(i), indj(l))*f(indj(i),&
                          indi(l))&
                          )*rind(l&
                          )
                    sigp(i,kpg) = sigp(i,kpg) + ftf*sigma(l)
                end do
                sigp(i,kpg) = sigp(i,kpg)/detf
            end do
        endif
!
    end do
end subroutine
