subroutine assesu(nno, nnos, nface, geom, crit,&
                  deplm, deplp, congem, congep, vintm,&
                  vintp, defgem, defgep, dsde, matuu,&
                  vectu, rinstm, rinstp, option, imate,&
                  mecani, press1, press2, tempe, dimdef,&
                  dimcon, dimuel, nbvari, ndim, compor,&
                  typmod, typvf, axi, perman)
    implicit none
!
! aslint: disable=W1501,W1504
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/r8prem.h"
#include "asterfort/assert.h"
#include "asterfort/cabhvf.h"
#include "asterfort/cacdsu.h"
#include "asterfort/cafmes.h"
#include "asterfort/cafves.h"
#include "asterfort/comthm.h"
#include "asterfort/inices.h"
#include "asterfort/nvithm.h"
#include "asterfort/rcvalb.h"
#include "asterfort/utmess.h"
#include "asterfort/vfcfks.h"
    integer, parameter :: maxfa=6
!
    integer :: nno, nnos, nface
    integer :: imate, dimdef, dimcon, dimuel
    integer :: mecani(5), press1(7), press2(7), tempe(5)
    integer :: nbvari, ndim, typvf
    real(kind=8) :: geom(ndim, nno), crit(*)
    real(kind=8) :: deplp(dimuel), deplm(dimuel)
    real(kind=8) :: congem(dimcon, maxfa+1), congep(dimcon, maxfa+1)
    real(kind=8) :: vintm(nbvari, maxfa+1), vintp(nbvari, maxfa+1)
    real(kind=8) :: defgem(dimdef), defgep(dimdef)
    real(kind=8) :: dsde(dimcon, dimdef)
    real(kind=8) :: matuu(dimuel*dimuel)
    real(kind=8) :: vectu(dimuel)
    real(kind=8) :: rinstp, rinstm
    character(len=8) :: typmod(2)
    character(len=16) :: option, compor(*)
    aster_logical :: axi, perman
!
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!      BUT :
!          CALCUL DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
!          EN MECANIQUE DES MILIEUX POREUX AVEC COUPLAGE THM
!
!
! IN NFACE NB DE FACES AU SENS BORD DE DIMENSION DIM-1 NE SERT QU EN VF
! IN NNOM NB DE NOEUDS MILIEUX DE FACE OU D ARRETE NE SERT QU EN EF
! IN NDDLS NB DE DDL SUR LES SOMMETS
! IN NDDLM NB DE DDL SUR LES MILIEUX DE FACE OU D ARETE UNIQUEMT EN EF
! IN NDDLFA NB DE DDL SUR LES FACE DE DIMENSION DIM-1 NE SERT QU EN VF
! IN NDDLK NB DE DDL AU CENTRE
! TYPVF     TYPE DE VF : 3 = SUDA (SUC ET SUDM ONT ETE SUPPRIMES)
! IN NDIM DIMENSION DE L'ESPACE
! IN DIMUEL NB DE DDL TOTAL DE L'ELEMENT
! IN DIMCON DIMENSION DES CONTRAINTES GENERALISEES ELEMENTAIRES
! IN DIMDEF DIMENSION DES DEFORMATIONS GENERALISEES ELEMENTAIRES
!
! ......................................................................
!
    integer :: con, dconp1, dconp2, diffu, ddifp1, ddifp2
    parameter(con=1,dconp1=2,dconp2=3,diffu=4,ddifp1=5,ddifp2=6)
!
    integer :: mob, dmobp1, dmobp2, masse, dmasp1, dmasp2
    parameter(mob=7,dmobp1=8,dmobp2=9,masse=10,dmasp1=11,dmasp2=12)
!
    integer :: wliq, wvap, airdis, airsec, eau, air, densit
    parameter(wliq=1,wvap=2,airdis=3,airsec=4,eau=1,air=2,densit=14)
!
    integer :: vkint, kxx, kyy, kzz, kxy, kyz, kzx
    parameter(vkint=13,kxx=1,kyy=2,kzz=3,kxy=4,kyz=5,kzx=6)
!
    integer :: rhoga, rholq, rhoga1, rhoga2, rholq1, rholq2
    parameter(rhoga=1,rholq=2,rhoga1=3,rhoga2=4,rholq1=5,rholq2=6)
!
    integer :: maxdim
    parameter (maxdim=3)
!
    integer :: yamec, yap1, yap2, yate
    integer :: addeme, addep1, addep2, addete, adcome, adcp11, adcp12, adcp21
    integer :: adcp22, adcote
    integer :: nvim, nvit, nvih, nvic
    integer :: advime, advith, advihy, advico
    integer :: vihrho, vicphi, vicpvp, vicsat, vicpr1, vicpr2
    integer :: ipg, retcom, fa, i, j
!
    real(kind=8) :: pesa(3), kintvf(6)
    real(kind=8) :: rthmc(1), p10, p20
    real(kind=8) :: valcen(14, 6), valfac(maxfa, 14, 6)
!
    aster_logical :: tange, cont, bool
!
    integer :: codmes(1), kpg, spt
    character(len=8) :: fami, poum
    character(len=16) :: thmc, loi, meca, ther, hydr
    character(len=24) :: valk(2)
!
! ==============================================
! VARIABLES LOCALES POUR CALCULS VF
! ==============================================
! PCP PRESSION CAPILLAIRE AU CENTRE DE LA MAILLE
! PWP PRESSION EAU
! DPWP1 DERIVEE PRESSION EAU PAR P1
! DPWP2 DERIVEE PRESSION EAU PAR P2
! PGP PRESSION DE GAZ AU CENTRE DE LA MAILLE
! CVP CONCENTRATION VAPEUR DANS PHASE GAZEUSE
! DCVP1 DERIVEE CVP /P1
! DCVP2 DERIVEE CVP /P2
! CAD ENTRATION AIR DISSOUS
! DCAD1 DERIVEE CAD /P1
! DCAD2 DERIVEE CAD /P2
!  VALFAC(I,CON,WLIQ)     CONCENTRATION DE L EAU LIQUIDE SUR ARRETE I
!  VALFAC(I,DCONP1,WLIQ)  D_CON_EAU_LIQU_I /P1
!  VALFAC(I,DCONP2,WLIQ)  D_CON_EAU_LIQU_I /P2
!  VALFAC(I,DIFFU,WLIQ)   DIFFUW SUR ARETE I
!  VALFAC(I,DDIFP1,WLIQ)  D_DIFFUW_I /P1
!  VALFAC(I,DDIFP2,WLIQ)  D_DIFFUW_I /P2
!  VALFAC(I,MOB,WLIQ)     MOBILITE DE L EAU LIQUIDE SUR ARETE I
!  VALFAC(I,DMOBP1,WLIQ)  D_MO_LIQU /P1_CENTRE
!  VALFAC(I,DMOBP2,WLIQ)  D_MO_LIQU /P2_CENTRE
! NB: DE MEME POUR WVAP(EAU VAPEUR),AIRDIS(AIR DISSOUS),AIRSEC(AIR SEC)
!  VALCEN(CON,WVAP)       CONCENTRATION EAU VAPEUR
!  VALCEN(DCONP1,WVAP)
!  VALCEN(DCONP2,WVAP)
! etc...
! =====================================================================
! VARIABLES LOCALES POUR CALCULS VF SUSHI
! =====================================================================
! PCPF PRESSION CAPILLAIRE SUR LA FACE
! PGPF PRESSION DE GAZ SUR LA FACE
! DPGP1F DERIVEE DE PRESSION DE GAZ /P1 SUR LA FACE
! DZGP2F DERIVEE DE PRESSION DE GAZ /P2 SUR LA FACE
! PWPF PRESSION EAU SUR LA FACE
! DPWP1F DERIVEE DE PRESSION EAU /P1 SUR LA FACE
! DPWP2F DERIVEE DE PRESSION EAU /P2 SUR LA FACE
! CVPF CONCENTRATION VAPEUR DANS PHASE GAZEUSE SUR LA FACE
! DCVP1F DERIVEE CVP /P1 SUR LA FACE
! DCVP2F DERIVEE CVP /P2 SUR LA FACE
! CADF CONCENTRATION AIR DISSOUS SUR LA FACE
! DCAD1F DERIVEE CAD /P1 SUR LA FACE
! DCAD2F DERIVEE CAD /P2 SUR LA FACE
! VALCEN(MOB,WLIQ) MOBILITE EAU SUR FACE
! VALCEN(DMOBP1,WLIQ) DERIVEE MOBILITE EAU /P1 SUR K
! VALCEN(DMOBP2,WLIQ) DERIVEE MOBILITE EAU /P2 SUR K
! etc ...
! DASP1F DERIVEE MOBILITE AIR SEC /P1 SUR FACE
! DASP2F DERIVEE MOBILITE AIR SEC /P2 SUR FACE
! FLKS FLUX (VOLUMIQUE) LIQUIDE F_{K,SIGMA}(PWP)
! DFLKS1 DERIVEE DE FLKS/P1
! DFLKS2 DERIVEE DE FLKS/P2
! FTGKS(IFA) FLUX (VOLUMIQUE)GAZ ~F_{K,SIGMA}
! SUR FACE IFA EN NUM DE K
! FTGKS1 DERIVEE DE FTGKS/P1 :
! FTGKS1(MAXFA+1,MAXFA,)
! FTGKS1( 1,IFA ) D_FTGKS(IFA)/DP1K
! FTGKS1(JFA+1,IFA ) D_FTGKS(IFA)/DP1_FACE_JFA_DE_K
! FTGKS2 DERIVEE DE FTGKS/P2
! FCLKS FLUX (VOLUMIQUE)LIQUIDE ^F_{K,SIGMA}(CAD)
! DFCLKS1 DERIVEE DE FCLKS/P1
! DFCLKS2 DERIVEE DE FCLKS/P2
! FTGKS FLUX (VOLUMIQUE)GAZ ~F_{K,SIGMA}(CVP)
! FTGKS1 DERIVEE DE FTGKS/P1 :
! FTGKS2 DERIVEE DE FTGKS/P2
! C MATRICE INTERVENANT DS LE CALCUL DES FLUX FGKS,FLKS
! D MATRICE INTERVENANT DS LE CALCUL DES FLUX FTGKS,FCLKS
! YSS MATRICE INTERVENANT DS LE CALCUL DES MATRICES C ET D
! FLUWS FLUX MASSIQUE EAU TOTAL DANS MAILLE SUSHI
! FLUVPS FLUX MASSIQUE VAPEUR TOTAL DANS MAILLE SUSHI
! FLUASS FLUX MASSIQUE AIR SEC TOTAL DANS MAILLE SUSHI
! FLUADS FLUX MASSIQUE AIR DISSOUS TOTAL DANS MAILLE SUSHI
! FW1S(MAXFA+1) DERIVEE FLUWS / P1_K PUIS P_1,SIGMA
! FW2S(MAXFA+1) DERIVEE FLUWS / P2_K PUIS P_2,SIGMA
! FVP1S(MAXFA+1) DERIVEE FLUVPS / P1_K PUIS P_1,SIGMA
! FVP2S(MAXFA+1) DERIVEE FLUVPS / P2_K PUIS P_2,SIGM
! FAS1S(MAXFA+1) DERIVEE FLUASS / P1_K PUIS P_1,SIGMA
! FAS2S(MAXFA+1) DERIVEE FLUASS / P2_K PUIS P_2,SIGMA
! FAD1S(MAXFA+1) DERIVEE FLUADS / P1_K PUIS P_1,SIGMA
! FAD2S(MAXFA+1) DERIVEE FLUADS / P2_K PUIS P_2,SIGMA
! FMVPS FLUX MASSIQUE VAPEUR INTERVENANT DS EQ DE CONTINUITE
! POUR UNE ARETE EXTERNE
! FMWS FLUX MASSIQUE EAU INTERVENANT DS EQ
! DE CONTINUITE POUR UNE ARETE EXTERNE
! FMASS FLUX MASSIQUE AIR SEC INTERVENANT DS EQ
! DE CONTINUITE POUR UNE ARETE EXTERNE
! FMADS FLUX MASSIQUE AIR DISSOUS INTERVENANT DS EQ
! DE CONTINUITE POUR UNE ARETE EXTERNE
! FM1VPS(MAXFA+1,NFACE) DERIVEE DE FMVPS / P_K PUIS P_1,SIGMA
! FM2VPS(MAXFA+1,NFACE) DERIVEE DE FMVPS / P_K PUIS P_2,SIGMA
! FM1WS(MAXFA+1,NFACE) DERIVEE DE FMWS / P_K PUIS P_1,SIGMA
! FM2WS(MAXFA+1,NFACE) DERIVEE DE FMWS / P_K PUIS P_2,SIGMA
! FM1ASS(MAXFA+1,NFACE) DERIVEE DE FMASS / P_K PUIS P_1,SIGMA
! FM2ASS(MAXFA+1,NFACE) DERIVEE DE FMASS / P_K PUIS P_2,SIGMA
! FM1ADS(MAXFA+1,NFACE) DERIVEE DE FMADS / P_K PUIS P_1,SIGMA
! FM2ADS(MAXFA+1,NFACE) DERIVEE DE FMADS / P_K PUIS P_2,SIGMA
! =====================================================================
! VARIABLES COMMUNES
! =====================================================================
    aster_logical :: vf
    real(kind=8) :: mface(maxfa), dface(maxfa), xface(maxdim, maxfa), normfa(maxdim, maxfa), vol
    integer :: ifa, jfa, idim
    real(kind=8) :: pcp, pwp, pgp, dpgp1, dpgp2, dpwp1, dpwp2
    real(kind=8) :: cvp, dcvp1, dcvp2, cad, dcad1, dcad2
! =====================================================================
! VARIABLES VF SUSHI
! =====================================================================
    real(kind=8) :: fluws, fluvps, fluass, fluads
    real(kind=8) :: fw1s(maxfa+1), fw2s(maxfa+1), fvp1s(maxfa+1)
    real(kind=8) :: fas1s(maxfa+1), fas2s(maxfa+1), fvp2s(maxfa+1)
    real(kind=8) :: fad1s(maxfa+1), fad2s(maxfa+1), fmvps(maxfa)
    real(kind=8) :: fmass(maxfa), fmads(maxfa), fmws(maxfa)
    real(kind=8) :: fm1vps(maxfa+1, maxfa), fm2vps(maxfa+1, maxfa)
    real(kind=8) :: fm1ws(maxfa+1, maxfa), fm2ws(maxfa+1, maxfa)
    real(kind=8) :: fm1ass(maxfa+1, maxfa), fm2ass(maxfa+1, maxfa)
    real(kind=8) :: fm1ads(maxfa+1, maxfa), fm2ads(maxfa+1, maxfa)
    real(kind=8) :: pcpf(maxfa), pgpf(maxfa), dpgp1f(maxfa), dpgp2f(maxfa), pwpf(maxfa)
    real(kind=8) :: dpwp1f(maxfa), dpwp2f(maxfa), cvpf(maxfa), dcvp1f(maxfa), cadf(maxfa)
    real(kind=8) :: dcad1f(maxfa), dcad2f(maxfa), dcvp2f(maxfa)
    real(kind=8) :: yss (maxdim, maxfa, maxfa)
    real(kind=8) :: c (maxfa, maxfa), d (maxfa, maxfa)
    real(kind=8) :: flks(maxfa), dflks1(maxfa+1, maxfa), dflks2(maxfa+1, maxfa), fgks(maxfa)
    real(kind=8) :: dfgks1(maxfa+1, maxfa), dfgks2(maxfa+1, maxfa), ftgks(maxfa)
    real(kind=8) :: ftgks1(maxfa+1, maxfa), ftgks2(maxfa+1, maxfa), fclks(maxfa)
    real(kind=8) :: fclks1(maxfa+1, maxfa), fclks2(maxfa+1, maxfa)
    real(kind=8) :: mobwf(maxfa), moadf(maxfa), moasf(maxfa), movpf(maxfa), dw1f(maxfa)
    real(kind=8) :: dw2f(maxfa), dvp1f(maxfa), das1f(maxfa), das2f(maxfa), dad1f(maxfa)
    real(kind=8) :: dvp2f(maxfa), dad2f(maxfa), dvp1ff(maxfa), dvp2ff(maxfa), dw1ffa(maxfa)
    real(kind=8) :: dw2ffa(maxfa), das1ff(maxfa), das2ff(maxfa), dad1ff(maxfa), dad2ff(maxfa)
    real(kind=8) :: divp1(maxfa), divp2(maxfa), diad1(maxfa), diad2(maxfa), dias1(maxfa)
    real(kind=8) :: dias2(maxfa), difuvp(maxfa), difuas(maxfa), difuad(maxfa), diad1f(maxfa)
    real(kind=8) :: diad2f(maxfa), dias1f(maxfa), dias2f(maxfa), divp1f(maxfa), divp2f(maxfa)
!=====================================================================
    real(kind=8) :: xg(maxdim)
    real(kind=8) :: rhol, rhog, drhol1, drhol2, drhog1, drhog2
    real(kind=8) :: alpha, zero
!     DANS LE CAS DES ELEMENTS FINIS ANGMAS EST NECESSAIRE
    real(kind=8) :: angbid(3)
    integer :: iadp1k, iadp2k
    integer :: adcm1, adcm2
! ====================================================
! ADRESSE DANS LA MATRICE DE L ELEMENT CALCULE PAR
! LE VOISIN IVOIS EN LIGNE LIG ET COLONNE COL
! LA CONTRIBUTION PROPRE CORRESPOND AU VOISIN 0
! DES DONNEES DES VOISINS DE LA MAILLE NUMA (0 SI MAILLE PAS ACTIVE)
! ====================================================
#define zzadma(ivois,lig,col) (ivois)*(dimuel)*(dimuel)+(lig-1)*(dimuel)+col
! ===================================================
! FONCTIONS FORMULES D ADRESSAGE DES DDL
! ===================================================
#define iadp1(fa) 2*(fa-1)+1
#define iadp2(fa) 2*(fa-1)+2
#define adcf1(fa) 2*(fa-1)+1
#define adcf2(fa) 2*(fa-1)+2
    iadp1k=2*nface+1
    iadp2k=2*nface+2
    adcm1 = 2*nface+1
    adcm2 = 2*nface+2
    call inices(valcen, valfac, maxfa)
!
    alpha = crit(18)
!============================
! LE CENTRE EST LE CENTRE DE GRAVITE (CENTRE DU CERCLE CIRCONSCRIT DESACTIVE
!===============================
    zero=0.d0
    do idim = 1, ndim
        xg(idim)=geom(idim,nno)
    end do
! ==============================
!   SI TYPVF=3 ALORS DECENTRE (SEUL SCHEMA RESTANT)
! ==============================
    if (typvf .ne. 3) call utmess('F', 'VOLUFINI_9', si=typvf)

    bool = (option(1:9).eq.'RIGI_MECA' ) .or. (option(1:9).eq.'RAPH_MECA' ) .or.&
           (option(1:9).eq.'FULL_MECA' )
    ASSERT(bool)
!
!
    vf = .true.
    perman = .false.
!
! ====================================================================
! --- DETERMINATION DES VARIABLES CARACTERISANT LE MILIEU ------------
! ====================================================================
    yamec = mecani(1)
    addeme = mecani(2)
    adcome = mecani(3)
    yap1 = press1(1)
    addep1 = press1(3)
    adcp11 = press1(4)
    adcp12 = press1(5)
    yap2 = press2(1)
    addep2 = press2(3)
    adcp21 = press2(4)
    adcp22 = press2(5)
    yate = tempe(1)
    addete = tempe(2)
    adcote = tempe(3)
! ====================================================================
! --- CALCUL DE CONSTANTES TEMPORELLES -------------------------------
! ====================================================================
!
    loi = ' '
    fami='FPG1'
    kpg=1
    spt=1
    poum='+'
    call rcvalb(fami, kpg, spt, poum, imate,&
                ' ', 'THM_INIT', 0, ' ', [0.d0],&
                1, 'COMP_THM', rthmc, codmes, 1)
    thmc = compor(8)
    if ((rthmc(1)-1.0d0) .lt. r8prem()) then
        loi = 'LIQU_SATU'
    else if ((rthmc(1)-2.0d0).lt.r8prem()) then
        loi = 'GAZ'
    else if ((rthmc(1)-3.0d0).lt.r8prem()) then
        loi = 'LIQU_VAPE'
    else if ((rthmc(1)-4.0d0).lt.r8prem()) then
        loi = 'LIQU_VAPE_GAZ'
    else if ((rthmc(1)-5.0d0).lt.r8prem()) then
        loi = 'LIQU_GAZ'
    else if ((rthmc(1)-6.0d0).lt.r8prem()) then
        loi = 'LIQU_GAZ_ATM'
    else if ((rthmc(1)-9.0d0).lt.r8prem()) then
        loi = 'LIQU_AD_GAZ_VAPE'
    else if ((rthmc(1)-10.0d0).lt.r8prem()) then
        loi = 'LIQU_AD_GAZ'
    endif
    if (thmc .ne. loi) then
        valk(1) = loi
        valk(2) = thmc
        call utmess('F', 'ALGORITH_34', nk=2, valk=valk)
    endif
! ====================================================================
! DECLARATION DE DEUX LOGIQUES POUR SAVOIR CE QUE L ON DOIT CALCULER
! TANGE => CALCUL OPERATEUR TANGENT => MATUU
! CONT => CALCUL RESIDU => VECTU
! ====================================================================
    cont = .false.
    tange = .false.
    if (option(1:9) .eq. 'RIGI_MECA') then
        tange = .true.
    else if (option(1:9).eq.'RAPH_MECA') then
        cont = .true.
    else if (option(1:9).eq.'FULL_MECA') then
        tange = .true.
        cont = .true.
    else
        valk(1) = option
        call utmess('F', 'VOLUFINI_11', sk=valk(1))
    endif
! ====================================================================
! --- INITIALISATION A ZERO MATUU ET VECTU
! ====================================================================
    if (tange) then
        do i = 1, dimuel*dimuel
            matuu(i)=0.d0
        end do
    endif
    if (cont) then
        do  i = 1, dimuel
            vectu(i)=0.d0
        end do
    endif
! ================================================================
! --- INITIALISATION
! ================================================================
    do i = 1, maxfa
        pcpf(i) =0.d0
        pgpf(i) =0.d0
        dpgp1f(i)=0.d0
        dpgp2f(i)=0.d0
        pwpf(i) =0.d0
        dpwp1f(i)=0.d0
        dpwp2f(i)=0.d0
        cvpf(i) =0.d0
        dcvp1f(i)=0.d0
        dcvp2f(i)=0.d0
        cadf(i) =0.d0
        dcad1f(i)=0.d0
        dcad2f(i)=0.d0
!
        mobwf(i) =0.d0
        dw1f(i) =0.d0
        dw2f(i) =0.d0
        dw1ffa(i)=0.d0
        dw2ffa(i)=0.d0
!
        moadf(i) = 0.d0
        dad1f(i) = 0.d0
        dad2f(i) = 0.d0
        dad1ff(i)= 0.d0
        dad2ff(i)= 0.d0
!
        moasf(i) = 0.d0
        das1f(i) = 0.d0
        das2f(i) = 0.d0
        das1ff(i)= 0.d0
        das2ff(i)= 0.d0
!
        movpf(i) = 0.d0
        dvp1f(i) = 0.d0
        dvp2f(i) = 0.d0
        dvp1ff(i)= 0.d0
        dvp2ff(i)= 0.d0
    end do
! ================================================================
! --- CALCUL DES QUANTITES GEOMETRIQUES
! ================================================================
    call cabhvf(maxfa, maxdim, ndim, nno, nnos,&
                nface, axi, geom, vol, mface,&
                dface, xface, normfa)
! ================================================================
! --- CALCUL DES DEFORMATIONS GENERALISEES ----------------------
! ON MET DANS LE TABLEAU DES DEF GENERALISES LES PRESSIONS
! LES GRADIENTS SONT MIS A ZERO CAR ON NE SAIT PAS LES CALCULER
! A CE NIVEAU EN VF4
! ================================================================
    if (yap1 .eq. 1) then
        defgem(addep1)= deplm(iadp1k)
        defgep(addep1)= deplp(iadp1k)
        do i = 1, ndim
            defgem(addep1+i)=0.d0
            defgep(addep1+i)=0.d0
        end do
        if (yap2 .eq. 1) then
            defgem(addep2)= deplm(iadp2k)
            defgep(addep2)= deplp(iadp2k)
            do i = 1, ndim
                defgem(addep2+i)=0.d0
                defgep(addep2+i)=0.d0
            end do
        endif
    endif
! ===============================================
! ==== INITIALISATION DE DSDE ================
! ===============================================
! INITIALISATION DE ANGMAS(3) À ZERO
    do i = 1, 3
        angbid(i)=0.d0
    end do
    do i = 1, dimcon
        do j = 1, dimdef
            dsde(i,j)=0.d0
        end do
    end do
    call comthm(option, perman, vf, 0, valfac,&
                valcen, imate, typmod, compor, crit,&
                rinstm, rinstp, ndim, dimdef, dimcon,&
                nbvari, yamec, yap1, yap2, yate,&
                addeme, adcome, addep1, adcp11, adcp12,&
                addep2, adcp21, adcp22, addete, adcote,&
                defgem, defgep, congem, congep, vintm(1, 1),&
                vintp(1, 1), dsde, pesa, retcom, 1,&
                1, p10, p20, angbid)
    if (retcom .ne. 0) then
        call utmess('F', 'COMPOR1_9')
    endif
    do fa = 1, nface
        if (yap1 .eq. 1) then
            defgem(addep1)= deplm(iadp1(fa))
            defgep(addep1)= deplp(iadp1(fa))
            do i = 1, ndim
                defgem(addep1+i)=0.d0
                defgep(addep1+i)=0.d0
            end do
            if (yap2 .eq. 1) then
                defgem(addep2)= deplm(iadp2(fa))
                defgep(addep2)= deplp(iadp2(fa))
                do i = 1, ndim
                    defgem(addep2+i)=0.d0
                    defgep(addep2+i)=0.d0
                end do
            endif
        else
            call utmess('F', 'VOLUFINI_9', si=typvf)
        endif
! ===============================================
! ==== INITIALISATION DE DSDE ================
! ===============================================
        do i = 1, dimcon
            do j = 1, dimdef
                dsde(i,j)=0.d0
            end do
        end do
        call comthm(option, perman, vf, fa, valfac,&
                    valcen, imate, typmod, compor, crit,&
                    rinstm, rinstp, ndim, dimdef, dimcon,&
                    nbvari, yamec, yap1, yap2, yate,&
                    addeme, adcome, addep1, adcp11, adcp12,&
                    addep2, adcp21, adcp22, addete, adcote,&
                    defgem, defgep, congem, congep, vintm(1, fa+1),&
                    vintp(1, fa+1), dsde, pesa, retcom, 1,&
                    1, p10, p20, angbid)
        if (retcom .ne. 0) then
            call utmess('F', 'COMPOR1_9')
        endif
    end do
    if (cont) then
        vectu(adcm1)=valcen(masse ,eau)*vol
        vectu(adcm2)=valcen(masse ,air)*vol
    endif
    if (tange) then
        matuu(zzadma(0,adcm1,iadp1k))=valcen(dmasp1,eau)*vol
        matuu(zzadma(0,adcm2,iadp1k))=valcen(dmasp1,air)*vol
        matuu(zzadma(0,adcm1,iadp2k))=valcen(dmasp2,eau)*vol
        matuu(zzadma(0,adcm2,iadp2k))=valcen(dmasp2,air)*vol
    endif
    rhol=valcen(densit ,rholq)
    drhol1=valcen(densit ,rholq1)
    drhol2=valcen(densit ,rholq2)
    rhog=valcen(densit ,rhoga)
    drhog1=valcen(densit ,rhoga1)
    drhog2=valcen(densit ,rhoga2)
    if (ndim .eq. 2) then
        kintvf(1) = valcen(vkint ,kxx)
        kintvf(2) = valcen(vkint ,kyy)
        kintvf(3) = valcen(vkint ,kxy)
        kintvf(4) = 0.d0
        kintvf(5) = 0.d0
        kintvf(6) = 0.d0
    else
        kintvf(1) = valcen(vkint ,kxx)
        kintvf(2) = valcen(vkint ,kyy)
        kintvf(3) = valcen(vkint ,kzz)
        kintvf(4) = valcen(vkint ,kxy)
        kintvf(5) = valcen(vkint ,kyz)
        kintvf(6) = valcen(vkint ,kzx)
    endif
    call cacdsu(maxfa, maxdim, alpha, ndim, nno,&
                nface, geom, vol, mface, dface,&
                xface, normfa, kintvf, yss, c,&
                d)
    pcp = deplp(iadp1k)
    pgp = deplp(iadp2k)
    if (loi .eq. 'LIQU_AD_GAZ') then
!
! ON STOCK PC ET PG DU CENTRE SUR TOUS LES POINTS DE GAUSS
! EN VUE DE POST TRAITEMENT
! CECI EST PROVISOIRE
!
        call nvithm(compor, meca, thmc, ther, hydr,&
                    nvim, nvit, nvih, nvic, advime,&
                    advith, advihy, advico, vihrho, vicphi,&
                    vicpvp, vicsat, vicpr1, vicpr2)
        do ipg = 1, nface+1
            vintp(advico+vicpr1,ipg) = pcp
            vintp(advico+vicpr2,ipg) = pgp
        end do
    endif
    dpgp1 = 0.d0
    dpgp2 = 1.d0
    do ifa = 1, nface
        pcpf(ifa) = deplp(iadp1(ifa))
        pgpf(ifa) = deplp(iadp2(ifa))
        dpgp1f(ifa) = 0.d0
        dpgp2f(ifa) = 1.d0
    end do
    pwp = pgp-pcp
    dpwp1 = -1.d0
    dpwp2 = +1.d0
    do ifa = 1, nface
        pwpf(ifa) = pgpf(ifa)-pcpf(ifa)
        dpwp1f(ifa) = -1.d0
        dpwp2f(ifa) = 1.d0
    end do
    cvp = valcen(con,wvap)
    dcvp1 = valcen(dconp1,wvap)
    dcvp2 = valcen(dconp2,wvap)
    do ifa = 1, nface
        cvpf (ifa) = valfac(ifa,con,wvap)
        dcvp1f(ifa) = valfac(ifa,dconp1,wvap)
        dcvp2f(ifa) = valfac(ifa,dconp2,wvap)
    end do
    cad = valcen(con,airdis)
    dcad1 = valcen(dconp1,airdis)
    dcad2 = valcen(dconp2,airdis)
    do ifa = 1, nface
        cadf(ifa) = valfac(ifa,con,airdis)
        dcad1f(ifa) = valfac(ifa,dconp1,airdis)
        dcad2f(ifa) = valfac(ifa,dconp2,airdis)
    end do
! ===========================================================
! INITIALISATION
! ===========================================================
    do ifa = 1, maxfa+1
        fw1s(ifa) =0.d0
        fw2s(ifa) =0.d0
        fvp1s(ifa)=0.d0
        fvp2s(ifa)=0.d0
        fas1s(ifa)=0.d0
        fas2s(ifa)=0.d0
        fad1s(ifa)=0.d0
        fad2s(ifa)=0.d0
    end do
    fluws =0.d0
    fluvps=0.d0
    fluass=0.d0
    fluads=0.d0
    do ifa = 1, maxfa
        fmvps(ifa)=0.d0
        fmws(ifa) =0.d0
        fmass(ifa)=0.d0
        fmads(ifa)=0.d0
        flks(ifa) =0.d0
        fgks(ifa) =0.d0
        fclks(ifa) =0.d0
        ftgks(ifa) =0.d0
    end do
    do  jfa = 1, maxfa
        do ifa = 1, maxfa+1
            dflks1(ifa,jfa)=0.d0
            dflks2(ifa,jfa)=0.d0
            dfgks1(ifa,jfa)=0.d0
            dfgks2(ifa,jfa)=0.d0
            ftgks1(ifa,jfa)=0.d0
            ftgks2(ifa,jfa)=0.d0
            fclks1(ifa,jfa)=0.d0
            fclks2(ifa,jfa)=0.d0
            fm1ws(ifa,jfa) =0.d0
            fm2ws(ifa,jfa) =0.d0
            fm1vps(ifa,jfa)=0.d0
            fm2vps(ifa,jfa)=0.d0
            fm1ass(ifa,jfa)=0.d0
            fm2ass(ifa,jfa)=0.d0
            fm1ads(ifa,jfa)=0.d0
            fm2ads(ifa,jfa)=0.d0
        end do
    end do
! ========================================
! FLUX VOLUMIQUES
!=========================================
    call vfcfks(.true._1, tange, maxfa, nface, cvp,&
                dcvp1, dcvp2, cvpf, dcvp1f, dcvp2f,&
                d, pesa, zero, zero, zero,&
                xg, xface, maxdim, ndim, ftgks,&
                ftgks1, ftgks2)
    call vfcfks(.true._1, tange, maxfa, nface, cad,&
                dcad1, dcad2, cadf, dcad1f, dcad2f,&
                d, pesa, zero, zero, zero,&
                xg, xface, maxdim, ndim, fclks,&
                fclks1, fclks2)
    call vfcfks(.true._1, tange, maxfa, nface, pwp,&
                dpwp1, dpwp2, pwpf, dpwp1f, dpwp2f,&
                c, pesa, rhol, drhol1, drhol2,&
                xg, xface, maxdim, ndim, flks,&
                dflks1, dflks2)
    call vfcfks(.true._1, tange, maxfa, nface, pgp,&
                dpgp1, dpgp2, pgpf, dpgp1f, dpgp2f,&
                c, pesa, rhog, drhog1, drhog2,&
                xg, xface, maxdim, ndim, fgks,&
                dfgks1, dfgks2)
    do ifa = 1, nface
! ========================================
! CALCUL DIFFUSIONS
! ========================================
        difuvp(ifa) = valcen(diffu,wvap)
        difuas(ifa) = -valcen(diffu,airsec)
        difuad(ifa) = valcen(diffu,airdis)
        divp1(ifa) = valcen(ddifp1,wvap)
        divp2(ifa) = valcen(ddifp2,wvap)
        divp1f(ifa) = 0.d0
        divp2f(ifa) = 0.d0
        dias1(ifa) = -valcen(ddifp1,airsec)
        dias2(ifa) = -valcen(ddifp2,airsec)
        dias1f(ifa) = 0.d0
        dias2f(ifa) = 0.d0
        diad1(ifa) = valcen(ddifp1,airdis)
        diad2(ifa) = valcen(ddifp2,airdis)
        diad1f(ifa) = 0.d0
        diad2f(ifa) = 0.d0
    end do
    do ifa = 1, nface
! ==========================================
! CALCUL MOBILITES
! ==========================================

! ===========================
! CALCUL MOBILITES
! ===========================
        if (flks(ifa) .ge. 0.d0) then
            mobwf(ifa) = valcen(mob,wliq)
            dw1f(ifa) = valcen(dmobp1,wliq)
            dw2f(ifa) = valcen(dmobp2,wliq)
            dw1ffa(ifa) = 0.d0
            dw2ffa(ifa) = 0.d0
!
            moadf(ifa) = valcen(mob,airdis)
            dad1f(ifa) = valcen(dmobp1,airdis)
            dad2f(ifa) = valcen(dmobp2,airdis)
            dad1ff(ifa)= 0.d0
            dad2ff(ifa)= 0.d0
        else
            mobwf(ifa) = valfac(ifa,mob,wliq)
            dw1f(ifa) = 0.d0
            dw2f(ifa) = 0.d0
            dw1ffa(ifa)=valfac(ifa,dmobp1,wliq)
            dw2ffa(ifa)= valfac(ifa,dmobp2,wliq)
!
            moadf(ifa) = valfac(ifa,mob,airdis)
            dad1f(ifa) = 0.d0
            dad2f(ifa) = 0.d0
            dad1ff(ifa)= valfac(ifa,dmobp1,airdis)
            dad2ff(ifa)= valfac(ifa,dmobp2,airdis)
        endif
        if (fgks(ifa) .ge. 0.d0) then
            moasf(ifa) = valcen(mob,airsec)
            das1f(ifa) = valcen(dmobp1,airsec)
            das2f(ifa) = valcen(dmobp2,airsec)
            das1ff(ifa)= 0.d0
            das2ff(ifa)= 0.d0
!
            movpf(ifa) = valcen(mob,wvap)
            dvp1f(ifa) = valcen(dmobp1,wvap)
            dvp2f(ifa) = valcen(dmobp2,wvap)
            dvp1ff(ifa)= 0.d0
            dvp2ff(ifa)= 0.d0
        else
            moasf(ifa) = valfac(ifa,mob,airsec)
            das1f(ifa) = 0.d0
            das2f(ifa) = 0.d0
            das1ff(ifa)= valfac(ifa,dmobp1,airsec)
            das2ff(ifa)= valfac(ifa,dmobp2,airsec)
!
            movpf(ifa) = valfac(ifa,mob,wvap)
            dvp1f(ifa) = 0.d0
            dvp2f(ifa) = 0.d0
            dvp1ff(ifa)= valfac(ifa,dmobp1,wvap)
            dvp2ff(ifa)= valfac(ifa,dmobp2,wvap)
        endif
    end do
    do ifa = 1, nface
        call cafmes(ifa, .true._1, tange, maxfa, nface,&
                    flks(ifa), dflks1, dflks2, mobwf(ifa), dw1f,&
                    dw2f, dw1ffa, dw2ffa, fmws, fm1ws,&
                    fm2ws)
        call cafmes(ifa, .true._1, tange, maxfa, nface,&
                    fgks(ifa), dfgks1, dfgks2, movpf(ifa), dvp1f,&
                    dvp2f, dvp1ff, dvp2ff, fmvps, fm1vps,&
                    fm2vps)
        call cafmes(ifa, cont, tange, maxfa, nface,&
                    ftgks(ifa), ftgks1, ftgks2, difuvp(ifa), divp1,&
                    divp2, divp1f, divp2f, fmvps, fm1vps,&
                    fm2vps)
        call cafmes(ifa, .true._1, tange, maxfa, nface,&
                    fgks(ifa), dfgks1, dfgks2, moasf(ifa), das1f,&
                    das2f, das1ff, das2ff, fmass, fm1ass,&
                    fm2ass)
        call cafmes(ifa, cont, tange, maxfa, nface,&
                    ftgks(ifa), ftgks1, ftgks2, difuas(ifa), dias1,&
                    dias2, dias1f, dias2f, fmass, fm1ass,&
                    fm2ass)
        call cafmes(ifa, .true._1, tange, maxfa, nface,&
                    flks(ifa), dflks1, dflks2, moadf(ifa), dad1f,&
                    dad2f, dad1ff, dad2ff, fmads, fm1ads,&
                    fm2ads)
        call cafmes(ifa, cont, tange, maxfa, nface,&
                    fclks(ifa), fclks1, fclks2, difuad(ifa), diad1,&
                    diad2, diad1f, diad2f, fmads, fm1ads,&
                    fm2ads)
    end do
    call cafves(.true._1, tange, maxfa, nface, flks,&
                dflks1, dflks2, mobwf, dw1f, dw2f,&
                dw1ffa, dw2ffa, fluws, fw1s, fw2s)
    call cafves(.true._1, tange, maxfa, nface, fgks,&
                dfgks1, dfgks2, movpf, dvp1f, dvp2f,&
                dvp1ff, dvp2ff, fluvps, fvp1s, fvp2s)
    call cafves(.true._1, tange, maxfa, nface, ftgks,&
                ftgks1, ftgks2, difuvp, divp1, divp2,&
                divp1f, divp2f, fluvps, fvp1s, fvp2s)
    call cafves(.true._1, tange, maxfa, nface, fgks,&
                dfgks1, dfgks2, moasf, das1f, das2f,&
                das1ff, das2ff, fluass, fas1s, fas2s)
    call cafves(.true._1, tange, maxfa, nface, ftgks,&
                ftgks1, ftgks2, difuas, dias1, dias2,&
                dias1f, dias2f, fluass, fas1s, fas2s)
    call cafves(.true._1, tange, maxfa, nface, flks,&
                dflks1, dflks2, moadf, dad1f, dad2f,&
                dad1ff, dad2ff, fluads, fad1s, fad2s)
    call cafves(.true._1, tange, maxfa, nface, fclks,&
                fclks1, fclks2, difuad, diad1, diad2,&
                diad1f, diad2f, fluads, fad1s, fad2s)
    if (cont) then
! ********************************************************************
! EQUATION DE LA CONTINUITE DES FLUX
!           | FMWS + FMVPS |
!           | FMASS + FMADS |
! ********************************************************************
        do ifa = 1, nface
            congep(adcp11+1,ifa+1)=fmws(ifa)+fmvps(ifa)
            congep(adcp12+1,ifa+1)=fmass(ifa)+fmads(ifa)
            vectu(adcf1(ifa))=congep(adcp11+1,ifa+1)
            vectu(adcf2(ifa))=congep(adcp12+1,ifa+1)
        end do
! ********************************************************************
! EQUATION DE LA CONSERVATION DE LA MASSE
!
!           | FLUWS + FLUVPS |
!           | FLUASS + FLUADS |
! ********************************************************************
        congep(adcp11+1,1)= fluws
        congep(adcp12+1,1)= fluvps
        congep(adcp21+1,1)= fluass
        congep(adcp22+1,1)= fluads
        vectu(adcm1)= vectu(adcm1)+congep(adcp11+1,1) +congep(adcp12+&
        1,1)
        vectu(adcm2)= vectu(adcm2)+congep(adcp21+1,1) +congep(adcp22+&
        1,1)
    endif
    if (tange) then
! *******************************************************************
! EQUATION DE LA CONSERVATION DE LA MASSE POUR K
!           (DERIVEES % VARIABLES DU CENTRE)
!           SANS LA PARTIE FICKIENNE POUR INTERNE ET EXTERNE
!           | FW1S + FVP1S |
!           | FW2S + FVP2S |
!           | FAS1S + FAD1S |
!           | FAS2S + FAD2S |
! *******************************************************************
        matuu(zzadma(0,adcm1,iadp1k))= matuu(zzadma(0,adcm1,iadp1k))+&
        fw1s(1)+fvp1s(1)
!
        matuu(zzadma(0,adcm1,iadp2k))= matuu(zzadma(0,adcm1,iadp2k))+&
        fw2s(1)+fvp2s(1)
!
        matuu(zzadma(0,adcm2,iadp1k))= matuu(zzadma(0,adcm2,iadp1k))+&
        fas1s(1)+fad1s(1)
!
        matuu(zzadma(0,adcm2,iadp2k))= matuu(zzadma(0,adcm2,iadp2k))+&
        fas2s(1)+fad2s(1)
        do ifa = 1, nface
!
! *******************************************************************
! EQUATION DE LA CONSERVATION DE LA MASSE POUR K
!           (DERIVEES % VARIABLES DE L ARETE)
!           POUR INTERNE ET EXTERNE
!           | FW1S + FVP1S |
!           | FW2S + FVP2S |
!           | FAS1S + FAD1S |
!           | FAS2S + FAD2S |
! *******************************************************************
            matuu(zzadma(0,adcm1,iadp1(ifa)))= matuu(zzadma(0,adcm1,iadp1(ifa))) +&
                fw1s(ifa+1)+fvp1s(ifa+1)
!
            matuu(zzadma(0,adcm1,iadp2(ifa)))= matuu(zzadma(0,adcm1,iadp2(ifa))) +&
                fw2s(ifa+1)+fvp2s(ifa+1)
!
            matuu(zzadma(0,adcm2,iadp1(ifa)))= matuu(zzadma(0,adcm2,iadp1(ifa))) +&
                fas1s(ifa+1)+fad1s(ifa+1)
!
            matuu(zzadma(0,adcm2,iadp2(ifa)))= matuu(zzadma(0,adcm2,iadp2(ifa))) +&
                fas2s(ifa+1)+fad2s(ifa+1)
! *******************************************************************
! EQUATION DE LA CONTINUITE DES FLUX POUR K
!           (DERIVEES % VARIABLES DU CENTRE)
!           | FM1WS + FM1VPS |
!           | FM2WS + FM2VPS |
!           | FM1ASS + FM1ADS |
!           | FM2ASS + FM2ADS |
! *****************************************************************
            matuu(zzadma(0,adcf1(ifa),iadp1k))= matuu(zzadma(0,adcf1(ifa),iadp1k)) +&
                fm1ws(1,ifa)+fm1vps(1,ifa)
!
            matuu(zzadma(0,adcf1(ifa),iadp2k))= matuu(zzadma(0,adcf1(ifa),iadp2k)) +&
                fm2ws(1,ifa)+fm2vps(1,ifa)
!
            matuu(zzadma(0,adcf2(ifa),iadp1k))= matuu(zzadma(0,adcf2(ifa),iadp1k)) +&
                fm1ass(1,ifa)+fm1ads(1,ifa)
!
            matuu(zzadma(0,adcf2(ifa),iadp2k))= matuu(zzadma(0,adcf2(ifa),iadp2k)) +&
                fm2ass(1,ifa)+fm2ads(1,ifa)
! *******************************************************************
! EQUATION DE LA CONTINUITE DES FLUX POUR K
!           (DERIVEES % VARIABLES DE L ARETE)
!           | FM1WS + FM1VPS |
!           | FM2WS + FM2VPS |
!           | FM1ASS + FM1ADS |
!           | FM2ASS + FM2ADS |
! *******************************************************************
            do jfa = 1, nface
                matuu(zzadma(0,adcf1(ifa),iadp1(jfa)))= matuu(zzadma(0,adcf1(ifa),iadp1(jfa))) +&
                    fm1ws(jfa+1,ifa)+fm1vps(jfa+1,ifa)
!
                matuu(zzadma(0,adcf1(ifa),iadp2(jfa)))= matuu(zzadma(0,adcf1(ifa),iadp2(jfa))) +&
                    fm2ws(jfa+1,ifa)+fm2vps(&
                jfa+1,ifa)
!
                matuu(zzadma(0,adcf2(ifa),iadp1(jfa)))= matuu(zzadma(0,adcf2(ifa),iadp1(jfa))) +&
                    fm1ass(jfa+1,ifa)+fm1ads(jfa+1,ifa)
!
                matuu(zzadma(0,adcf2(ifa),iadp2(jfa)))= matuu(zzadma(0,adcf2(ifa),iadp2(jfa))) +&
                    fm2ass(jfa+1,ifa)+fm2ads(&
                jfa+1,ifa)
            end do
        end do
    endif
end subroutine
