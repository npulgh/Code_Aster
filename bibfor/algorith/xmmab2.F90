subroutine xmmab2(ndim, jnne, ndeple, nnc, jnnm,&
                  hpg, ffc, ffe,&
                  ffm, jacobi, lambda, coefcr,&
                  coeffr, jeu, coeffp,&
                  lpenaf, coefff, tau1, tau2, rese,&
                  nrese, mproj, norm, nsinge,&
                  nsingm, fk_escl, fk_mait, nvit, nconta,&
                  jddle, jddlm, nfhe,nfhm, heavn, mmat)
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
!
! aslint: disable=W1504
    implicit none
#include "asterf_types.h"
#include "asterfort/indent.h"
#include "asterfort/xplma2.h"
#include "asterfort/mkkvec.h"
#include "asterfort/normev.h"
#include "asterfort/xcalc_heav.h"
#include "asterfort/xcalc_code.h"
    integer :: ndim, nnc, jnne(3), jnnm(3)
    integer :: nsinge, nsingm, nfhe
    integer :: nvit, nconta, ndeple, jddle(2), jddlm(2)
    integer :: nfhm, heavn(*)
    real(kind=8) :: hpg, ffc(8), ffe(20), ffm(20), jacobi, norm(3)
    real(kind=8) :: lambda, coefff, coeffr, coefcr, coeffp
    real(kind=8) :: tau1(3), tau2(3), rese(3), nrese, mmat(336, 336)
    real(kind=8) :: mproj(3, 3)
    real(kind=8) :: jeu
    real(kind=8) :: fk_escl(27,3,3), fk_mait(27,3,3)
    aster_logical :: lpenaf
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
!
! CALCUL DE B ET DE BT POUR LE CONTACT METHODE CONTINUE
! SANS ADHERENCE
!
! ----------------------------------------------------------------------
!
! ----------------------------------------------------------------------
! ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
! TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
! ----------------------------------------------------------------------
!
! IN  NDIM   : DIMENSION DU PROBLEME
! IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
! IN  NNES   : NOMBRE DE NOEUDS SOMMETS DE LA MAILLE ESCLAVE
! IN  NNC    : NOMBRE DE NOEUDS DE CONTACT
! IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
! IN  NFAES  : NUMERO DE LA FACETTE DE CONTACT ESCLAVE
! IN  CFACE  : MATRICE DE CONECTIVITE DES FACETTES DE CONTACT
! IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
! IN  FFC    : FONCTIONS DE FORME DU PT CONTACT DANS ELC
! IN  FFE    : FONCTIONS DE FORME DU PT CONTACT DANS ESC
! IN  FFM    : FONCTIONS DE FORME DE LA PROJECTION DU PTC DANS MAIT
! IN  NDDLSE : NOMBRE DE DDLS D'UN NOEUD SOMMET ESCLAVE
! IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
! IN  JPCAI  : POINTEUR VERS LE VECTEUR DES ARRETES ESCLAVES
!              INTERSECTEES
! IN  LAMBDA : VALEUR DU SEUIL
! IN  COEFFA : COEF_REGU_FROT
! IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
! IN  TAU1   : PREMIERE TANGENTE
! IN  TAU2   : SECONDE TANGENTE
! IN  RESE   : PROJECTION DE LA BOULE UNITE POUR LE FROTTEMENT
! IN  NRESE  : RACINE DE LA NORME DE RESE
! IN  MPROJ  : MATRICE DE L'OPERATEUR DE PROJECTION
! IN  TYPMAI : NOM DE LA MAILLE ESCLAVE D'ORIGINE (QUADRATIQUE)
! IN  NSINGE : NOMBRE DE FONCTION SINGULIERE ESCLAVE
! IN  NSINGM : NOMBRE DE FONCTION SINGULIERE MAITRE
! IN  RRE    : SQRT LST ESCLAVE
! IN  RRM    : SQRT LST MAITRE
! IN  NVIT   : POINT VITAL OU PAS
! I/O MMAT   : MATRICE ELEMENTAIRE DE CONTACT/FROTTEMENT
!
! ----------------------------------------------------------------------
!
    integer :: i, j, k, l, ii, jj, pli, plj, iin, jjn, ddle
    integer :: nne, nnes, nnm, nnms, ddles, ddlem, ddlms, ddlmm
    integer :: hea_fa(2), alpj, alpi
    real(kind=8) :: c1(3), c2(3), c3(3), d1(3), d2(3), d3(3), h1(3), h2(3)
    real(kind=8) :: g(3, 3), d(3, 3), b(3, 3), c(3, 3), r(3, 3), mp, mb, mbt, mm
    real(kind=8) :: mmt
    real(kind=8) :: tt(3, 3)
    real(kind=8) :: iescl(2), jescl(2), imait(2), jmait(2)
! ----------------------------------------------------------------------
!
! --- INITIALISATIONS
!
    iescl(1) = 1
    iescl(2) = -1
    jescl(1) = 1
    jescl(2) = -1
    imait(1) = 1
    imait(2) = 1
    jmait(1) = 1
    jmait(2) = 1
!    DEFINITION A LA MAIN DE LA TOPOLOGIE DE SOUS-DOMAINE PAR FACETTE (SI NFISS=1)
    hea_fa(1)=xcalc_code(1,he_inte=[-1])
    hea_fa(2)=xcalc_code(1,he_inte=[+1])
!
    nne=jnne(1)
    nnes=jnne(2)
    nnm=jnnm(1)
    nnms=jnnm(2)
    ddles=jddle(1)
    ddlem=jddle(2)
    ddlms=jddlm(1)
    ddlmm=jddlm(2)
!
    do 1 i = 1, 3
        do 2 j = 1, 3
            g(i,j) = 0.d0
            d(i,j) = 0.d0
            b(i,j) = 0.d0
            r(i,j) = 0.d0
            tt(i,j)=0.d0
  2     continue
  1 continue
    do 3 k = 1, 3
        c1(k) = mproj(k,1)
        c2(k) = mproj(k,2)
        c3(k) = mproj(k,3)
        d1(k) = 0.d0
        d2(k) = 0.d0
        d3(k) = 0.d0
        h1(k) = 0.d0
        h2(k) = 0.d0
  3 continue
!
! --- G = [K][P_TAU]
!
    call mkkvec(rese, nrese, ndim, c1, d1)
    call mkkvec(rese, nrese, ndim, c2, d2)
    call mkkvec(rese, nrese, ndim, c3, d3)
!
    do 4 k = 1, ndim
        g(k,1) = d1(k)
        g(k,2) = d2(k)
        g(k,3) = d3(k)
  4 continue
!
! --- D = [P_TAU]*[K]*[P_TAU]
!
    do 13 i = 1, ndim
        do 14 j = 1, ndim
            do 15 k = 1, ndim
                d(i,j) = g(k,i)*mproj(k,j) + d(i,j)
 15         continue
 14     continue
 13 continue
!
    call mkkvec(rese, nrese, ndim, tau1, h1)
    call mkkvec(rese, nrese, ndim, tau2, h2)
!
! --- B = [P_B,[K]TAU1,[K]TAU2]*[P_TAU]
!
    call normev(rese, nrese)
    do 24 i = 1, ndim
        do 25 k = 1, ndim
            b(1,i) = rese(k)*mproj(k,i)+b(1,i)
            b(2,i) = h1(k)*mproj(k,i)+b(2,i)
            b(3,i) = h2(k)*mproj(k,i)+b(3,i)
 25     continue
 24 continue
!
! --- C = (P_B)[P_TAU]*(N)
!
    do 8 i = 1, ndim
        do 9 j = 1, ndim
            c(i,j) = b(1,i)*norm(j)
  9     continue
  8 continue
!
! --- R = [TAU1,TAU2][ID-K][TAU1,TAU2]
!
    do 857 k = 1, ndim
        r(1,1) = (tau1(k)-h1(k))*tau1(k) + r(1,1)
        r(1,2) = (tau1(k)-h1(k))*tau2(k) + r(1,2)
        r(2,1) = (tau2(k)-h2(k))*tau1(k) + r(2,1)
        r(2,2) = (tau2(k)-h2(k))*tau2(k) + r(2,2)
857 continue
!
!---- TT = [TAU1,TAU2][ID][TAU1,TAU2]
!
    do 301 i = 1, ndim
        tt(1,1) = tau1(i)*tau1(i) + tt(1,1)
        tt(1,2) = tau1(i)*tau2(i) + tt(1,2)
        tt(2,1) = tau2(i)*tau1(i) + tt(2,1)
        tt(2,2) = tau2(i)*tau2(i) + tt(2,2)
301 continue
!
    if (nconta .eq. 3 .and. ndim .eq. 3) then
        mp = (lambda-coefcr*jeu)*coefff*hpg*jacobi
    else
        mp = lambda*coefff*hpg*jacobi
    endif
!
    ddle = ddles*nnes+ddlem*(nne-nnes)
!
    if (nnm .ne. 0) then
!
! --------------------- CALCUL DE [A] ET [B] -----------------------
!
        do 70 l = 1, ndim
            do 10 k = 1, ndim
                if (l .eq. 1) then
! SUPPRESSION DU TERME EN AT DANS LE CAS DU GLISSEMENT
                    mb = 0.d0
                    if (nconta .eq. 3 .and. ndim .eq. 3) then
                        mbt = coefff*hpg*jacobi*b(l,k)
                    else
                        mbt = 0.d0
                    endif
                else
                    if (.not.lpenaf) then
                        if (nconta .eq. 3 .and. ndim .eq. 3) then
                            mb = nvit*hpg*jacobi*b(l,k)
                        else
                            mb = nvit*mp*b(l,k)
                        endif
                    endif
                    if (lpenaf) mb = 0.d0
                    if (.not.lpenaf) mbt = mp*b(l,k)
                    if (lpenaf) mbt = 0.d0
                endif
                do 20 i = 1, nnc
                    call xplma2(ndim, nne, nnes, ddles, i,&
                                nfhe, pli)
                    ii = pli+l-1
                    do 30 j = 1, ndeple
! --- BLOCS ES:CONT, CONT:ES
                        mm = mb*ffc(i)*ffe(j)
                        mmt= mbt*ffc(i)*ffe(j)
                        call indent(j, ddles, ddlem, nnes, jjn)
                        jj = jjn+k
                        jescl(2)=xcalc_heav(heavn(j),&
                                            hea_fa(1),&
                                            heavn(nfhe*nne+nfhm*nnm+j))
                        mmat(ii,jj) = -jescl(1)*mm
                        mmat(jj,ii) = -jescl(1)*mmt
                        jj = jj + ndim
                        mmat(ii,jj) = -jescl(2)*mm
                        mmat(jj,ii) = -jescl(2)*mmt
                        do 40 alpj = 1, nsinge*ndim
                            jj = jjn + (1+nfhe+1-1)*ndim + alpj
                            mmat(ii,jj) = mmat(ii,jj)+mb*ffc(i)*fk_escl(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)+mbt*ffc(i)*fk_escl(j,alpj,k)
 40                     continue
 30                 continue
                    do 50 j = 1, nnm
! --- BLOCS MA:CONT, CONT:MA
                        mm = mb*ffc(i)*ffm(j)
                        mmt= mbt*ffc(i)*ffm(j)
                        call indent(j, ddlms, ddlmm, nnms, jjn)
                        jj = ddle + jjn + k
                        jmait(2)=xcalc_heav(heavn(nne+j),&
                                            hea_fa(2),&
                                            heavn((1+nfhe)*nne+nfhm*nnm+j))
                        mmat(ii,jj) = jmait(1)*mm
                        mmat(jj,ii) = jmait(1)*mmt
                        jj = jj + ndim
                        mmat(ii,jj) = jmait(2)*mm
                        mmat(jj,ii) = jmait(2)*mmt
                        do 60 alpj = 1, nsingm*ndim
                            jj = jjn + (1+nfhm+1-1)*ndim + alpj
                            mmat(ii,jj) = mmat(ii,jj)+mb*ffc(i)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)+mbt*ffc(i)*fk_mait(j,alpj,k)
 60                     continue
 50                 continue
 20             continue
 10         continue
 70     continue
!
! --------------------- CALCUL DE [BU] ---------------------------------
!
        do 100 k = 1, ndim
            do 110 l = 1, ndim
                if (lpenaf) then
                    mb = -mp*coeffp*d(l,k)
                    mbt = -mp*coeffp*d(l,k)
                else
                    if (nconta .eq. 3 .and. ndim .eq. 3) then
                        mb = -mp*coeffr*d(l,k)+coefcr*coefff*hpg* jacobi*c(l,k)
                        mbt = -mp*coeffr*d(l,k)+coefcr*coefff*hpg* jacobi*c(l,k)
                    else
                        mb = -mp*coeffr*d(l,k)
                        mbt = -mp*coeffr*d(l,k)
                    endif
                endif
                do 200 i = 1, ndeple
                    iescl(2)=xcalc_heav(heavn(i),&
                                        hea_fa(1),&
                                        heavn(nfhe*nne+nfhm*nnm+i))
                    do 210 j = 1, ndeple
                        jescl(2)=xcalc_heav(heavn(j),&
                                            hea_fa(1),&
                                            heavn(nfhe*nne+nfhm*nnm+j))
! --- BLOCS ES:ES
                        mm = mb *ffe(i)*ffe(j)
                        mmt= mbt*ffe(i)*ffe(j)
                        call indent(i, ddles, ddlem, nnes, iin)
                        call indent(j, ddles, ddlem, nnes, jjn)
                        ii = iin + l
                        jj = jjn + k
                        mmat(ii,jj) = iescl(1)*jescl(1)*mm
                        jj = jj + ndim
                        mmat(ii,jj) = iescl(1)*jescl(2)*mm
                        mmat(jj,ii) = iescl(1)*jescl(2)*mmt
                        ii = ii + ndim
                        mmat(ii,jj) = iescl(2)*jescl(2)*mm
                        do 215 alpj = 1, nsinge*ndim
                            jj = jjn + (1+nfhe+1-1)*ndim + alpj
                            ii = iin + l
                            mmat(ii,jj) = mmat(ii,jj)-iescl(1)*mb*ffe(i)*fk_escl(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)-iescl(1)*mbt*ffe(i)*fk_escl(j,alpj,k)
                            ii = ii + ndim
                            mmat(ii,jj) = mmat(ii,jj)-iescl(2)*mb*ffe(i)*fk_escl(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)-iescl(2)*mbt*ffe(i)*fk_escl(j,alpj,k)
                            do alpi = 1, nsinge*ndim 
                            ii = iin + (1+nfhe+1-1)*ndim + alpi
                            mmat(ii,jj) = mmat(ii,jj)+mb*fk_escl(i,alpi,l)*fk_escl(j,alpj,k)
                            enddo
215                     continue
210                 continue
                    do 220 j = 1, nnm
                        jmait(2)=xcalc_heav(heavn(nne+j),&
                                            hea_fa(2),&
                                            heavn((1+nfhe)*nne+nfhm*nnm+j))
! --- BLOCS ES:MA, MA:ES
                        mm = mb *ffe(i)*ffm(j)
                        mmt= mbt*ffe(i)*ffm(j)
                        call indent(i, ddles, ddlem, nnes, iin)
                        call indent(j, ddlms, ddlmm, nnms, jjn)
                        ii = iin + l
                        jj = ddle + jjn + k
                        mmat(ii,jj) = -iescl(1)*jmait(1)*mm
                        mmat(jj,ii) = -iescl(1)*jmait(1)*mmt
                        jj = jj + ndim
                        mmat(ii,jj) = -iescl(1)*jmait(2)*mm
                        mmat(jj,ii) = -iescl(1)*jmait(2)*mmt
                        ii = ii + ndim
                        jj = jj - ndim
                        mmat(ii,jj) = -iescl(2)*jmait(1)*mm
                        mmat(jj,ii) = -iescl(2)*jmait(1)*mmt
                        jj = jj + ndim
                        mmat(ii,jj) = -iescl(2)*jmait(2)*mm
                        mmat(jj,ii) = -iescl(2)*jmait(2)*mmt
                        do 230 alpj = 1, nsingm*ndim
                            ii = iin + l
                            jj = ddle + jjn + (1+nfhm+1-1)*ndim + alpj
                            mmat(ii,jj) = mmat(ii,jj)-iescl(1)*mb*ffe(i)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)-iescl(1)*mbt*ffe(i)*fk_mait(j,alpj,k)
                            ii = ii + ndim
                            mmat(ii,jj) = mmat(ii,jj)-iescl(2)*mb*ffe(i)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)-iescl(2)*mbt*ffe(i)*fk_mait(j,alpj,k)
230                     continue
                        do 240 alpi = 1, nsinge*ndim
                            ii = iin + (1+nfhm+1-1)*ndim + alpi
                            jj = ddle + jjn + k
                            mmat(ii,jj) = mmat(ii,jj)+jmait(1)*mb*ffm(j)*fk_escl(i,alpi,l)
                            mmat(jj,ii) = mmat(jj,ii)+jmait(1)*mbt*ffm(j)*fk_escl(i,alpi,l)
                            jj = jj + ndim
                            mmat(ii,jj) = mmat(ii,jj)+jmait(2)*mb*ffm(j)*fk_escl(i,alpi,l)
                            mmat(jj,ii) = mmat(jj,ii)+jmait(2)*mbt*ffm(j)*fk_escl(i,alpi,l)
240                     continue
                        do 250 alpi = 1, nsinge*ndim
                          do alpj = 1, nsingm*ndim
                            ii = iin + (1+nfhm+1-1)*ndim + alpi
                            jj = ddle + jjn + (1+nfhm+1-1)*ndim + alpj
                            mmat(ii,jj) = mmat(ii,jj)+mb*fk_escl(i,alpi,l)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)+mbt*fk_escl(i,alpi,l)*fk_mait(j,alpj,k)
                          enddo
250                     continue
220                 continue
200             continue
                do 300 i = 1, nnm
                    imait(2)=xcalc_heav(heavn(nne+i),&
                                        hea_fa(2),&
                                        heavn((1+nfhe)*nne+nfhm*nnm+i))  
                    do 320 j = 1, nnm
                        jmait(2)=xcalc_heav(heavn(nne+j),&
                                            hea_fa(2),&
                                            heavn((1+nfhe)*nne+nfhm*nnm+j))
! --- BLOCS MA:MA
                        mm = mb *ffm(i)*ffm(j)
                        mmt= mbt*ffm(i)*ffm(j)
                        call indent(i, ddlms, ddlmm, nnms, iin)
                        call indent(j, ddlms, ddlmm, nnms, jjn)
                        ii = ddle + iin + l
                        jj = ddle + jjn + k
                        mmat(ii,jj) = imait(1)*jmait(1)*mm
                        jj = jj + ndim
                        mmat(ii,jj) = imait(1)*jmait(2)*mm
                        mmat(jj,ii) = imait(1)*jmait(2)*mmt
                        ii = ii + ndim
                        mmat(ii,jj) = imait(2)*jmait(2)*mm
                        do 330 alpj = 1, nsingm*ndim
                            jj = ddle + jjn + (1+nfhm+1-1)*ndim + alpj
                            ii = ddle + iin + l
                            mmat(ii,jj) = mmat(ii,jj)+imait(1)*mb*ffm(i)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = mmat(jj,ii)+imait(1)*mbt*ffm(i)*fk_mait(j,alpj,k)
                            ii = ii + ndim
                            mmat(ii,jj) = imait(2)*mb*ffm(i)*fk_mait(j,alpj,k)
                            mmat(jj,ii) = imait(2)*mbt*ffm(i)*fk_mait(j,alpj,k)
                            do alpi = 1, nsingm*ndim 
                            ii = ddle + iin + (1+nfhm+1-1)*ndim + alpi
                            mmat(ii,jj) = mmat(ii,jj)+mb*fk_mait(i,alpi,l)*fk_mait(j,alpj,k)
                            enddo
330                     continue
320                 continue
300             continue
110         continue
100     continue
!
    else
!
! --------------------- CALCUL DE [A] ET [B] -----------------------
!
        do 550 l = 1, ndim
            do 510 k = 1, ndim
                if (l .eq. 1) then
                    mb = 0.d0
                    if (nconta .eq. 3 .and. ndim .eq. 3) then
                        mbt = coefff*hpg*jacobi*b(l,k)
                    else
                        mbt = 0.d0
                    endif
                else
                    if (.not.lpenaf) then
                        if (nconta .eq. 3 .and. ndim .eq. 3) then
                            mb = nvit*hpg*jacobi*b(l,k)
                        else
                            mb = nvit*mp*b(l,k)
                        endif
                    endif
                    if (lpenaf) mb = 0.d0
                    if (.not.lpenaf) mbt = mp*b(l,k)
                    if (lpenaf) mbt = 0.d0
                endif
                do 520 i = 1, nnc
                    call xplma2(ndim, nne, nnes, ddles, i,&
                                nfhe, pli)
                    ii = pli+l-1
                    do 530 j = 1, ndeple
! --- BLOCS ES:CONT, CONT:ES
                        mm = mb *ffc(i)
                        mmt= mbt*ffc(i)
                        call indent(j, ddles, ddlem, nnes, jjn)
                        do alpj = 1, nsinge*ndim
                           jj = jjn + alpj
                           mmat(ii,jj) = mmat(ii,jj)-mm*fk_escl(j,alpj,k)
                           if (.not.lpenaf) mmat(jj,ii) = mmat(jj,ii)+mmt*fk_escl(j,alpj,k)
                        enddo
530                 continue
520             continue
510         continue
550     continue
!
! --------------------- CALCUL DE [BU] ---------------------------------
!
        do 600 k = 1, ndim
            do 610 l = 1, ndim
                if (lpenaf) then
                    mb = -mp*coeffp*d(l,k)
                else
                    if (nconta .eq. 3 .and. ndim .eq. 3) then
                        mb = -mp*coeffr*d(l,k)+coefcr*coefff*hpg* jacobi*c(l,k)
                    else
                        mb = -mp*coeffr*d(l,k)
                    endif
                endif
                do 620 i = 1, ndeple
                    do 630 j = 1, ndeple
! --- BLOCS ES:ES
                        mm = mb *ffe(i)*ffe(j)
                        call indent(i, ddles, ddlem, nnes, iin)
                        call indent(j, ddles, ddlem, nnes, jjn)
                        do alpj = 1, nsinge*ndim
                          do alpi = 1, nsinge*ndim
                            ii = iin + alpi
                            jj = jjn + alpj
                            mmat(ii,jj) = mmat(ii,jj)+mb * fk_escl(i,alpi,l)*fk_escl(j,alpj,k)
                          enddo
                        enddo
630                 continue
620             continue
610         continue
600     continue
    endif
!
! --------------------- CALCUL DE [F] ----------------------------------
!
    if (nvit .eq. 1) then
        do 400 i = 1, nnc
            do 410 j = 1, nnc
                call xplma2(ndim, nne, nnes, ddles, i,&
                            nfhe, pli)
                call xplma2(ndim, nne, nnes, ddles, j,&
                            nfhe, plj)
                do 420 l = 1, ndim-1
                    do 430 k = 1, ndim-1
                        ii = pli+k
                        jj = plj+l
                        if (lpenaf) then
                            mmat(ii,jj) = hpg*jacobi*ffc(i)*ffc(j)*tt( k,l)
                        else
                            if (nconta .eq. 3 .and. ndim .eq. 3) then
                                mmat(ii,jj) = jacobi*hpg*ffc(i)*ffc(j) *r(k,l)/coeffr
                            else
                                mmat(ii,jj) = mp*ffc(i)*ffc(j)*r(k,l)/ coeffr
                            endif
                        endif
430                 continue
420             continue
410         continue
400     continue
    endif
! ------------------- CALCUL DE [E] ------------------------------------
!
! ------------- COUPLAGE MULTIPLICATEURS CONTACT-FROTTEMENT ------------
    if (nvit .eq. 1) then
        do 800 i = 1, nnc
            do 810 j = 1, nnc
                call xplma2(ndim, nne, nnes, ddles, i,&
                            nfhe, pli)
                call xplma2(ndim, nne, nnes, ddles, j,&
                            nfhe, plj)
                do 830 k = 1, ndim-1
                    ii = pli+k
                    jj = plj
                    if (lpenaf) then
                        mmat(ii,jj) = 0.d0
                    else
                        mmat(ii,jj) = 0.d0
                    endif
830             continue
!
810         continue
800     continue
    endif
end subroutine
