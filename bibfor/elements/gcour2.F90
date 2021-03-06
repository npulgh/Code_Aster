subroutine gcour2(resu, noma, nomo, nomno, coorn,&
                  nbnoeu, trav1, trav2, trav3, fonoeu, chfond, basfon,&
                  nomfiss, connex, stok4, liss,&
                  nbre, milieu, ndimte, norfon)
    implicit none
!     ------------------------------------------------------------------
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!
! FONCTION REALISEE:
!
! 1.  POUR CHAQUE NOEUD DU FOND DE FISSURE GAMM0 ON RECUPERE
!     LE TRIPLET ( MODULE(THETA), RINF, RSUP )
!
! 2.  PUIS ON  CALCULE LA DIRECTION DES CHAMPS THETA
!     APPEL A GDIREC
!
! 3.  ENSUITE ON CALCULE LES CHAMPS THETA SUR TOUS LES NOEUDS DU
!     MAILLAGE
!
!     ------------------------------------------------------------------
! ENTREE:
!        RESU   : NOM DU CONCEPT RESULTAT
!        NOMA   : NOM DU CONCEPT MAILLAGE
!        NOMO   : NOM DU CONCEPT MODELE
!        NOMNO  : NOM DE L'OBJET CONTENANT LES NOEUDS DU MAILLAGE
!        COORN  : NOM DE L'OBJET CONTENANT LES COORDONNEES DU MAILLAGE
!        NBNOEU : NOMBRE DE NOEUDS DE GAMM0
!        FONOEU : NOMS DES NOEUDS DU FOND DE FISSURE
!        CHFOND : NOM DE L'OBJET CONTENANT LES COORDONNEES DES NOEUDS DE GAMM0
!        NOMFISS: NOM DU CONCEPT FOND_FISS
!        TRAV1  : RINF
!        TRAV2  : RSUP
!        LISS   : TYPE DE LISSAGE
!        NBRE   : DEGRE DES POLYNOMES DE LEGENDRE
!                     SINON 0
!        CONNEX: .TRUE.  : FOND DE FISSURE FERME
!                .FALSE. : FOND DE FISSURE DEBOUCHANT
! SORTIE:
!        STOK4  : DIRECTION DU CHAMP THETA
!                 LISTE DE CHAMPS_NO THETA
!        TRAV3 : MODULE(THETA)
!        MILIEU: .TRUE.  : ELEMENT QUADRATIQUE
!                .FALSE. : ELEMENT LINEAIRE
!     ------------------------------------------------------------------
!
!
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/getres.h"
#include "asterc/r8maem.h"
#include "asterc/r8prem.h"
#include "asterfort/assert.h"
#include "asterfort/codent.h"
#include "asterfort/dismoi.h"
#include "asterfort/gabscu.h"
#include "asterfort/gdinor.h"
#include "asterfort/gdirec.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvis.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeecra.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/lcprsn.h"
#include "asterfort/normev.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
#include "blas/dcopy.h"
!
    character(len=24) :: trav1, trav2, trav3, objor, objex, fonoeu, repk
    character(len=24) :: obj3, norm, numgam, chamno, chfond, basfon
    character(len=24) :: stok4, dire4, coorn, nomno, dire5, indicg
    character(len=24) :: liss, norfon
    character(len=16) :: k16b, nomcmd
    character(len=8) :: nomfiss, resu, noma, nomo, k8b
    character(len=6) :: kiord
!
    integer :: nbnoeu, iadrt1, iadrt2, iadrt3, itheta, ifon
    integer :: in2, iadrco, jmin, ielinf, iadnum, jvect
    integer :: iadrno, num, indic, iadrtt, nbre, nbr8, nbptfd
    integer :: iret, numa, ndimte, iaorig, iebas
    integer :: itanex, itanor, iaextr, jnorm
!
    real(kind=8) :: dirx, diry, dirz, xi1, yi1, zi1, xj1, yj1, zj1
    real(kind=8) :: xij, yij, zij, eps, d, tei, tej, dir(3)
    real(kind=8) :: xm, ym, zm, xim, yim, zim, s, dmin, smin, xn, yn, zn
    real(kind=8) :: rii, rsi, alpha, valx, valy, valz, norm2, psca
    real(kind=8) :: norme, vecx, vecy, vecz, tmpv(3)
!
    aster_logical :: milieu, connex
!
!-----------------------------------------------------------------------
    integer :: i, idesc, idiri, idirs, ielsup, inorfon
    integer :: ienorm, irefe, j, jresu, k, nbel
!-----------------------------------------------------------------------
    call jemarq()
!
    call getres(k8b, k16b, nomcmd)
!
    eps = 1.d-06
    call jeveuo(trav1, 'L', iadrt1)
    call jeveuo(trav2, 'L', iadrt2)
    call jeveuo(trav3, 'E', iadrt3)
    call jeveuo(fonoeu, 'L', iadrno)
    call jeveuo(coorn, 'L', iadrco)
    call jeveuo(chfond, 'L', ifon)    

!
! VERIFICATION SI MAILLAGE QUADRATIQUE OU NON
!
    call dismoi('ELEM_VOLU_QUAD', nomo, 'MODELE', repk=repk)
    if (repk .eq. 'OUI') then
        milieu = .true.
    else if (repk.eq.'NON') then
        milieu = .false.
    endif 
!
! VERIFICATION PRESENCE NB_POINT_FOND
!
    call getvis('THETA', 'NB_POINT_FOND', iocc=1, nbval=1, nbret=nbptfd)
!
! SI PRESENCE NB_POINT_FOND ALORS NOEUDS MILIEU ABSENTS

    if (nbptfd .ne. 0) then
        milieu = .false.
    endif
!
! INTERDICTION D AVOIR NB_POINT_FOND AVEC LISSAGES
! LAGRANGE_NO_NO, MIXTE OU LEGENDRE
!
    if (nbptfd .ne. 0) then
        if ((liss.eq.'LEGENDRE').or.(liss.eq.'MIXTE')&
           .or.(liss.eq.'LAGRANGE_NO_NO')) then
            call utmess('F', 'RUPTURE1_73')
        endif
    endif
!
! RECUPERATION DES DIRECTIONS AUX EXTREMITES DE GAMM0
!
    objor = nomfiss//'.DTAN_ORIGINE'
    call jeexin(objor, itanor)
    objex = nomfiss//'.DTAN_EXTREMITE'
    call jeexin(objex, itanex)
!
! RECUPERATION  DES NUMEROS DE NOEUDS DE GAMM0
!
    numgam = '&&COURON.NUMGAMM0'
    call wkvect(numgam, 'V V I', nbnoeu, iadnum)
    do j = 1, nbnoeu
        call jenonu(jexnom(nomno, zk8(iadrno+j-1)), zi(iadnum+j-1))      
    enddo
!
!  SI LEVRE_SUP EST DEFINIE DANS LE CONCEPT FOND
!
    obj3 = nomfiss//'.LEVRESUP.MAIL'
    call jeexin(obj3, ielsup)
!
!  SI LEVRE_INF EST DEFINIE DANS LE CONCEPT FOND
!
    obj3 = nomfiss//'.LEVREINF.MAIL'
    call jeexin(obj3, ielinf)
!
!  SI NORMALE EST DEFINIE DANS LE CONCEPT FOND
!
    norm = nomfiss//'.NORMALE        '
    call jeexin(norm, ienorm)
!
    stok4 = '&&COURON.DIREC'
    call wkvect(stok4, 'V V R', 3*nbnoeu, in2)
!
    dire4 = '&&COURON.LEVRESUP'
    dire5 = '&&COURON.LEVREINF'
!
!  RECUPERATION DIRECTION DU CHAMP THETA
!
!     DANS LE CAS OU LA NORMALE EST DEFINIE DANS DEFI_FOND_FISS/NORMALE,
!     ON AVERTIT L'UTILISATEUR PAR UNE ALARME SI LA DIRECTION N'EST PAS
!     FOURNIE
    call getvr8('THETA', 'DIRECTION', iocc=1, nbval=3, vect=dir,&
                nbret=nbr8)
    if (nbr8 .eq. 0 .and. ienorm .ne. 0) then
        call utmess('A', 'RUPTURE0_91')
    endif
!     ON VERIFIE QUE LA DIRECTION FOURNIE EST ORTHOGONALE A LA NORMALE
    if (nbr8 .ne. 0 .and. ienorm .ne. 0) then
        call jeveuo(norm, 'L', jnorm)
        call dcopy(3, zr(jnorm), 1, tmpv, 1)
        call normev(dir, norme)
        call normev(tmpv, norme)
        call lcprsn(3, dir, tmpv, psca)
        if (abs(psca) .gt. 0.1d0) then
            call utmess('F', 'RUPTURE0_94')
        endif
    endif
!
! 1ER CAS: LA DIRECTION DE THETA EST DONNEE, ON LA NORME
!
    if (nbr8 .ne. 0) then
!
        norme = 0.d0
        do i = 1, 3
            norme = norme + dir(i)*dir(i)
        end do
        norme = sqrt(norme)
        do i = 1, nbnoeu
            zr(in2+(i-1)*3+1-1) = dir(1)/norme
            zr(in2+(i-1)*3+2-1) = dir(2)/norme
            zr(in2+(i-1)*3+3-1) = dir(3)/norme
        end do
!
    else
!      LA DIRECTION DE THETA EST DONNEE DANS BASEFOND SI ON UTILISE NB_POINT_FOND
        if (nbptfd .ne. 0) then
            call jeveuo(basfon, 'L', jvect)
            do i = 1, nbnoeu
                zr(in2+(i-1)*3+1-1) = zr(jvect-1+6*(i-1)+4)
                zr(in2+(i-1)*3+2-1) = zr(jvect-1+6*(i-1)+5)
                zr(in2+(i-1)*3+3-1) = zr(jvect-1+6*(i-1)+6)
            end do
            
!      LA DIRECTION DE THETA EST CALCULEE DANS GDIREC PUIS ON LA NORME
!
!  LEVRE SUPERIEURE        
        else if (ielsup .ne. 0) then
            call gdirec(noma, nomfiss, 'LEVRESUP', nomno, zk8(iadrno),&
                        coorn, nbnoeu, dire4, milieu)
            call jeveuo(dire4, 'L', idirs)
            if (ielinf .ne. 0) then
!
!  LEVRE INFERIEURE
!
                call gdirec(noma, nomfiss, 'LEVREINF', nomno, zk8(iadrno),&
                            coorn, nbnoeu, dire5, milieu)
                call jeveuo(dire5, 'L', idiri)
!
! LES DIRECTIONS OBTENUES POUR CHAQUE LEVRE SONT MOYENNEES ET NORMEES
!
                do i = 1, nbnoeu
                    dirx = zr(idiri+(i-1)*3+1-1)
                    diry = zr(idiri+(i-1)*3+2-1)
                    dirz = zr(idiri+(i-1)*3+3-1)
                    vecx = (zr(idirs+(i-1)*3+1-1)+dirx)/2
                    vecy = (zr(idirs+(i-1)*3+2-1)+diry)/2
                    vecz = (zr(idirs+(i-1)*3+3-1)+dirz)/2
                    norme = sqrt(vecx*vecx + vecy*vecy + vecz*vecz)
                    zr(in2+(i-1)*3+1-1) = vecx/norme
                    zr(in2+(i-1)*3+2-1) = vecy/norme
                    zr(in2+(i-1)*3+3-1) = vecz/norme
                end do
            else
                do i = 1, nbnoeu
                    dirx = zr(idirs+(i-1)*3+1-1)
                    diry = zr(idirs+(i-1)*3+2-1)
                    dirz = zr(idirs+(i-1)*3+3-1)
                    norme = sqrt(dirx*dirx + diry*diry + dirz*dirz)
                    zr(in2+(i-1)*3+1-1) = dirx/norme
                    zr(in2+(i-1)*3+2-1) = diry/norme
                    zr(in2+(i-1)*3+3-1) = dirz/norme
                end do
            endif
        else if (ienorm.ne.0) then
            call gdinor(norm, nbnoeu, iadnum, coorn, in2)
        else
            call jeveuo(basfon, 'L', jvect)
            do i = 1, nbnoeu
                zr(in2+(i-1)*3+1-1) = zr(jvect-1+6*(i-1)+4)
                zr(in2+(i-1)*3+2-1) = zr(jvect-1+6*(i-1)+5)
                zr(in2+(i-1)*3+3-1) = zr(jvect-1+6*(i-1)+6)
            end do
        endif
!
!  ON RECUPERE LES DIRECTIONS UTILISATEUR AUX EXTREMITES DU FOND
!
        if (itanor .ne. 0) then
            call jeveuo(objor, 'L', iaorig)
            vecx = zr(iaorig)
            vecy = zr(iaorig+1)
            vecz = zr(iaorig+2)
            norme = sqrt(vecx*vecx + vecy*vecy + vecz*vecz)
            zr(in2+1-1) = vecx/norme
            zr(in2+2-1) = vecy/norme
            zr(in2+3-1) = vecz/norme
        endif
        if (itanex .ne. 0) then
            call jeveuo(objex, 'L', iaextr)
            vecx = zr(iaextr)
            vecy = zr(iaextr+1)
            vecz = zr(iaextr+2)
            norme = sqrt(vecx*vecx + vecy*vecy + vecz*vecz)
            zr(in2+3*(nbnoeu-1)+1-1) = vecx/norme
            zr(in2+3*(nbnoeu-1)+2-1) = vecy/norme
            zr(in2+3*(nbnoeu-1)+3-1) = vecz/norme
        endif
!
    endif
!
!     CORRECTION AUX EXTREMITES DU FOND
    call jeexin(basfon, iebas)
    if (iebas .ne. 0) then
        call jeveuo(basfon, 'L', jvect)
        zr(in2+1-1) = zr(jvect-1+4)
        zr(in2+2-1) = zr(jvect-1+5)
        zr(in2+3-1) = zr(jvect-1+6)
        zr(in2+(nbnoeu-1)*3+1-1) = zr(jvect-1+6*(nbnoeu-1)+4)
        zr(in2+(nbnoeu-1)*3+2-1) = zr(jvect-1+6*(nbnoeu-1)+5)
        zr(in2+(nbnoeu-1)*3+3-1) = zr(jvect-1+6*(nbnoeu-1)+6)
    endif
!
    norfon= '&&NORM.STOCK'
    call wkvect(norfon, 'V V R', 3*nbnoeu, inorfon)
!
!   stockage des directions des normales au fond de fissure
    call jeexin(nomfiss//'.BASEFOND', iebas)
!
    if (iebas .ne. 0) then
!       * cas general : la base du fond de fissure est definie et on 
!                       copie la normale
        call jeveuo(basfon, 'L', jvect)
        do i = 1, nbnoeu
            zr(inorfon+(i-1)*3+1-1) = zr(jvect-1+(i-1)*6+4)
            zr(inorfon+(i-1)*3+2-1) = zr(jvect-1+(i-1)*6+5)
            zr(inorfon+(i-1)*3+3-1) = zr(jvect-1+(i-1)*6+6)
        end do
    else
!   * cas particulier : la base locale n'est pas définie,
!       e.g. si l'utilisateur donne le champ de normale dans
!       DEFI_FOND_FISS
!       on copie la direction du champ theta et on aura donc
!       theta . n = 1, pour un champ theta norme
        do i = 1, nbnoeu
            zr(inorfon+(i-1)*3+1-1) = zr(in2+(i-1)*3+1-1)
            zr(inorfon+(i-1)*3+2-1) = zr(in2+(i-1)*3+2-1)
            zr(inorfon+(i-1)*3+3-1) = zr(in2+(i-1)*3+3-1)
        end do
    endif
!
! ALLOCATION D UN OBJET INDICATEUR DU CHAMP THETA SUR GAMMO
!
    call dismoi('NB_NO_MAILLA', noma, 'MAILLAGE', repi=nbel)

    indicg = '&&COURON.INDIC        '
    
    call wkvect(indicg, 'V V I', nbel, indic)
!
!
! ALLOCATION DES OBJETS POUR STOCKER LE CHAMP_NO THETA ET LA DIRECTION
! TYPE CHAM_NO ( DEPL_R) AVEC PROFIL NOEUD CONSTANT (3 DDL)
!
    if ((liss.eq.'LAGRANGE').or.(liss.eq.'LAGRANGE_NO_NO').or.(liss.eq.'MIXTE')) then
        ndimte = nbnoeu
    else
        ndimte = nbre + 1
    endif
!
    call wkvect(resu, 'V V K24', ndimte+1, jresu)
!
! CREATION DES NDIMTE+1 CHAMPS_NO ET VALEUR SUR GAMMA0
!
    do k = 1, ndimte+1
        call codent(k, 'D0', kiord)
        chamno = resu(1:8)//'_CHAM'//kiord//'     '
        zk24(jresu+k-1) = chamno
        call jeexin(chamno(1:19)//'.DESC', iret)
        ASSERT(iret.ge.0 .and. iret.le.100)
        if (iret .eq. 0) then
            call jedetr(chamno(1:19)//'.DESC')
            call jedetr(chamno(1:19)//'.REFE')
            call jedetr(chamno(1:19)//'.VALE')
        endif
!
!
!  .DESC
        chamno(20:24) = '.DESC'
        call wkvect(chamno, 'V V I', 3, idesc)
!
        call jeecra(chamno, 'DOCU', cval='CHNO')
        call jenonu(jexnom('&CATA.GD.NOMGD', 'DEPL_R'), numa)
        zi(idesc+1-1) = numa
        zi(idesc+2-1) = -3
        zi(idesc+3-1) = 14
!
!  .REFE
        chamno(20:24) = '.REFE'
        call wkvect(chamno, 'V V K24', 4, irefe)
        zk24(irefe+1-1) = noma//'                '
!
!  .VALE
        chamno(20:24) = '.VALE'
        call wkvect(chamno, 'V V R', 3*nbel, itheta)
!
        if (k .ne. (ndimte+1)) then
!
            if ((liss.eq.'LAGRANGE').or.(liss.eq.'LAGRANGE_NO_NO')&
            .or.(liss.eq.'MIXTE')) then
                if (nbptfd.eq.0) then
                    do i = 1, nbnoeu
                        num = zi(iadnum+i-1)
                        zr(itheta+(num-1)*3+1-1) = 0.d0
                        zr(itheta+(num-1)*3+2-1) = 0.d0
                        zr(itheta+(num-1)*3+3-1) = 0.d0
                        zi(indic+num-1) = 1
                    end do
                    num = zi(iadnum+k-1)
                    iadrtt = iadrt3 + (k-1)*nbnoeu + k - 1
                    zr(iadrtt) = 1.d0
                    zr(itheta+(num-1)*3+1-1) = zr(iadrtt)*zr(in2+(k-1)*3+ 1-1)
                    zr(itheta+(num-1)*3+2-1) = zr(iadrtt)*zr(in2+(k-1)*3+ 2-1)
                    zr(itheta+(num-1)*3+3-1) = zr(iadrtt)*zr(in2+(k-1)*3+ 3-1)
                    if (connex .and. (k.eq.1)) then
                        num = zi(iadnum+ndimte-1)
                        iadrtt = iadrt3 + (k-1)*nbnoeu + ndimte - 1
                        zr(iadrtt) = 1.d0
                        zr(itheta+(num-1)*3+1-1)=zr(iadrtt)*zr(in2+(&
                        ndimte-1)*3+1-1)
                        zr(itheta+(num-1)*3+2-1)=zr(iadrtt)*zr(in2+(&
                        ndimte-1)*3+2-1)
                        zr(itheta+(num-1)*3+3-1)=zr(iadrtt)*zr(in2+(&
                        ndimte-1)*3+3-1)
                    endif
                    if (connex .and. (k.eq.ndimte)) then
                        num = zi(iadnum+1-1)
                        iadrtt = iadrt3 + (k-1)*nbnoeu + 1 - 1
                        zr(iadrtt) = 1.d0
                        zr(itheta+(num-1)*3+1-1) = zr(iadrtt)*zr(in2+(1-1) *3+1-1)
                        zr(itheta+(num-1)*3+2-1) = zr(iadrtt)*zr(in2+(1-1) *3+2-1)
                        zr(itheta+(num-1)*3+3-1) = zr(iadrtt)*zr(in2+(1-1) *3+3-1)
                    endif
                else
                    zr(iadrt3-1+(k-1)*nbnoeu+k) = 1.d0
                    if (connex .and. (k.eq.1)) then
                        iadrtt = iadrt3 + (k-1)*nbnoeu + ndimte - 1
                        zr(iadrtt) = 1.d0
                    endif
                    if (connex .and. (k.eq.ndimte)) then
                        iadrtt = iadrt3 + (k-1)*nbnoeu + 1 - 1
                        zr(iadrtt) = 1.d0
                    endif
                endif
            else
                if (nbptfd.eq.0) then
                    do i = 1, nbnoeu
                        num = zi(iadnum+i-1)
                        iadrtt = iadrt3 + (k-1)*nbnoeu + i - 1
                        zr(itheta+(num-1)*3+1-1) = zr(iadrtt)*zr(in2+(i-1) *3+1-1)
                        zr(itheta+(num-1)*3+2-1) = zr(iadrtt)*zr(in2+(i-1) *3+2-1)
                        zr(itheta+(num-1)*3+3-1) = zr(iadrtt)*zr(in2+(i-1) *3+3-1)
                        zi(indic+num-1) = 1
                    end do
                else
                    do i = 1, nbnoeu
                        zr(iadrt3-1+(k-1)*nbnoeu+i) = 1.d0
                    end do 
                endif
            endif
        else
!     STOCKAGE DE LA DIRECTION DU CHAMPS THETA SUR LE FOND DE FISSURE
            if (nbptfd.eq.0) then
                do i = 1, nbnoeu
                    num = zi(iadnum+i-1)
                    zr(itheta+(num-1)*3+1-1) = zr(in2+(i-1)*3+1-1)
                    zr(itheta+(num-1)*3+2-1) = zr(in2+(i-1)*3+2-1)
                    zr(itheta+(num-1)*3+3-1) = zr(in2+(i-1)*3+3-1)
                end do
            endif
        endif
    end do
!
!         BOUCLE SUR LES NOEUDS M COURANTS DU MAILLAGE SANS GAMMO
!         POUR CALCULER PROJ(M)=N
!
    do i = 1, nbel
        if ((zi(indic+i-1) .ne. 1).or.(nbptfd.ne.0)) then
            zr(itheta+(i-1)*3+1-1) = 0.d0
            zr(itheta+(i-1)*3+2-1) = 0.d0
            zr(itheta+(i-1)*3+3-1) = 0.d0
            xm = zr(iadrco+(i-1)*3+1-1)
            ym = zr(iadrco+(i-1)*3+2-1)
            zm = zr(iadrco+(i-1)*3+3-1)
            dmin = r8maem()
            jmin = 0
            smin = 0.d0
            do j = 1, nbnoeu-1
                xi1 = zr(ifon-1+4*(j-1)+1)
                yi1 = zr(ifon-1+4*(j-1)+2)
                zi1 = zr(ifon-1+4*(j-1)+3)
                xj1 = zr(ifon-1+4*(j-1+1)+1)
                yj1 = zr(ifon-1+4*(j-1+1)+2)
                zj1 = zr(ifon-1+4*(j-1+1)+3)
                xij = xj1-xi1
                yij = yj1-yi1
                zij = zj1-zi1
                xim = xm-xi1
                yim = ym-yi1
                zim = zm-zi1
                s = xij*xim + yij*yim + zij*zim
                norm2 = xij*xij + yij *yij + zij*zij
                s = s/norm2
                if ((s-1) .ge. eps) then
                    s = 1.d0
                endif
                if (s .le. eps) then
                    s = 0.d0
                endif
                xn = s*xij+xi1
                yn = s*yij+yi1
                zn = s*zij+zi1
                d = sqrt((xn-xm)*(xn-xm)+(yn-ym)*(yn-ym)+ (zn-zm)*(zn- zm))
                if (d .lt. (dmin*(1-abs(r8prem())*1.d04))) then
                    dmin = d
                    jmin = j
                    smin = s
                endif
            end do
            rii = (1-smin)*zr(iadrt1+jmin-1)+smin*zr(iadrt1+jmin+1-1)
            rsi = (1-smin)*zr(iadrt2+jmin-1)+smin*zr(iadrt2+jmin+1-1)
            alpha = (dmin-rii)/(rsi-rii)
            do k = 1, ndimte+1
                call codent(k, 'D0', kiord)
                chamno = resu(1:8)//'_CHAM'//kiord//'     '
                chamno(20:24) = '.VALE'
                call jeveuo(chamno, 'E', itheta)
                if (k .ne. (ndimte+1)) then
                    iadrtt = iadrt3+(k-1)*nbnoeu+jmin-1
                    tei = zr(iadrtt)
                    tej = zr(iadrtt+1)
                    valx = (1-smin)*zr(in2+(jmin-1)*3+1-1)*tei
                    valx = valx+smin*zr(in2+(jmin+1-1)*3+1-1)*tej
                    valy = (1-smin)*zr(in2+(jmin-1)*3+2-1)*tei
                    valy = valy+smin*zr(in2+(jmin+1-1)*3+2-1)*tej
                    valz = (1-smin)*zr(in2+(jmin-1)*3+3-1)*tei
                    valz = valz+smin*zr(in2+(jmin+1-1)*3+3-1)*tej
!
                    if ((abs(alpha).le.eps) .or. (alpha.lt.0)) then
                        zr(itheta+(i-1)*3+1-1) = valx
                        zr(itheta+(i-1)*3+2-1) = valy
                        zr(itheta+(i-1)*3+3-1) = valz
                        else if((abs(alpha-1).le.eps).or.((alpha-1).gt.0))&
                    then
                        zr(itheta+(i-1)*3+1-1) = 0.d0
                        zr(itheta+(i-1)*3+2-1) = 0.d0
                        zr(itheta+(i-1)*3+3-1) = 0.d0
                    else
                        zr(itheta+(i-1)*3+1-1) = (1-alpha)*valx
                        zr(itheta+(i-1)*3+2-1) = (1-alpha)*valy
                        zr(itheta+(i-1)*3+3-1) = (1-alpha)*valz
                    endif
                else
                    zr(itheta+(i-1)*3+1-1) = 0.d0
                    zr(itheta+(i-1)*3+2-1) = 0.d0
                    zr(itheta+(i-1)*3+3-1) = 0.d0
                endif
            end do          
        endif
    end do
!
!
! DESTRUCTION D'OBJETS DE TRAVAIL
!
    call jeexin(dire4, iret)
    if (iret .ne. 0) call jedetr(dire4)
    call jeexin(dire5, iret)
    if (iret .ne. 0) call jedetr(dire5)
    call jedetr(indicg)
    call jedetr(numgam)
!
    call jedema()
!
end subroutine
