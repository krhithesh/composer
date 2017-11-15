ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.1
docker tag hyperledger/composer-playground:0.15.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� wuZ �=�r�v�Mr����[�T>�W߱je��y�� �H|I�l_m340b���B�n�nU^ ��wȏ<G^ ��3�������kN��>}����>���f(-d��1,�h��0G��m��� �!�g8&p�Oa��>���b�(��8>*��G�����c����m®j��[��+�.2-��w����02���������N��m���<�a�si�چ���w���Z��A�oJQԎaږK� ��涹��MCzW5��t{��<����y�0��fv�+/���oX�5��o�Ӈ�md��!F��A��.�H���Xn[�Fc�2�Z[��9�n�FVB��lR0X���Լb��m��B�n�EL6��#�ŝ��~j��t�,�:Rl�iG�QW54��u�ۚZVMU����S��{�Ҵ0��An�j���[���m�?�4�h8�C��ƃWã�B͚[��F�C�9�qs���L<�����rL���0;�N(�Q�K��h��`'�E���N�z����
ŝV��AG��j[�l��94|�t4W�/��kӶ;��
��d��E"2��S����A	v�=���>8Ȳ+��0��ԖΛ�C���'�m)�?y��mA���M��w=�x����f��+5T������F���^2�w�{���ޅ?�+p������y��:���Ef���_$����G��@��9�_��7e�m��(����k�j.[���������#"�#f�Z�_<�C���*���e8�� ��(5�QSM�b��Ri�tX)&���k<c�?�N�����5beO��x-�5��'�O���?Y��*`-�_7L��|C
I�,��Y��*ȯ����Z��n�"���`/,C��:��_�����O��QQX��W��4txݜԁ��\����I�,�:�%�f� �gm0�e�	pMH3:�)��N��$��ގ�v�V��ۦ�h��p�jf�zx��9���@k'�9M�J�X��g�ahV��g<��i��>�W��OS�[�n	KM�M��=�;�pY�U<ಪJKi¡מ��!jF���u;�5��Z- M��v�� �p��񾃠;YC$��Q��S�����hLB��`<8p��@�Ju���8���Yx|���DΠ.���k�z�3|�0��#iZ��/k.���;��q��z�_��?�	 Z�;:=�vڠ�j�z��mtND�tt]��Ca��l����a���ͧ5:�@�����m���v˂�/	I�Hi�����W{���W �'l�;�j�|R�L]ŕ�C���ڋ����oS��� �I�פ��4��FO�- -�C�İ�\�gG#�=���m1�n�y��c�.�4ޏI�]���Cf��.��L�����X�*`b�֧��_]��>���!�܁�
���ȅ1���ڴ�f�}��;��a�J�]�HC�B�BRl�k�JT�� ˸_�ݧtr� �l�z��@��s�T�>c<B}�:6��۟���3�FT�*7)��(k��gT�^P�Fy����D�CD�k^�,@Y�x�R��tdA��:Zo�_+L���D�7�/�����hx����������h,祈�ϋBtR�yn��Y	�zRj�q�3��@}4S4=�����2D�͘���h�ix��ʏa��T���	�	S�˖�K�b����^��W�c���glm~�!_o�����JnZJ���c�X��_^��fO�C ��B���[N�T�Fb�K�
��zA��,4�&�H,����,�,1Tn�[*K��y9��+��\��M㝏��U���h�X�]>ⶁ��&����[.�|��b� ޾�S+���4x�-�[�du�&��d����T+<)K�dAC';t��V<����fC�
��B���(��,b��=l������"z���B�����������Ԫ��?,�;`�t"R\C�Q���Ft� 	r xָ��M?�_��>0L���iߧ�H��<7�����Z�W�/�̓OU���6Pu< ��:��K0��1�!��־�:��)�?�0-_���c\�_���?5q���������?���s��_	�v����������8]��+���_��ᆎ�pӲ2M�|:���ށh���d�	@]��#��u�x��1#�{��8t����&
~���-5���Q�7�.���X}�Fm@��0��"O�^d�Lo�������x�O�����3f�VȄE¯�LS3�� )1O�6�u�'�=��Z�
Q��F{ytc.���"]�5Ǝ�1��8x�̙��3�;�Jנ��զ=�`M_�\�����̥�E�L����#�z�_,����JV���G�"bÆ��B>:嬂��Z�����8PoƓk�;t�A.(.�W����w�R����:Gi֪cE��m��K!�����'
����X,���?�I��-~�����xC7��Uk9���ȋF���X$�gM�����j��;�f�`�� ����<�~�#ϼ��k�=z8����> �t�;��*��*Cur�=��z�Z���h���#r�C0��(���Xn$�@��T��Oo6�-XW�!��<B5rnք]4N�s��lL��E���1��0���������ZW�/0� ?���4xBv�C��A��[%�u�{f�4���Z�>�����w+�F�4,�}��{��{��{@d򑐱2"�b��ރS^��x�h�KcuM>�1�!����7�6�p��ǽÜ|=�Ś���z�e�]����0G��T��������<�� M]m��E0M��W��E�&�9DW�Bt���F&f,��l���x^��ʡX�Z��v�ۮo�Q]��J\8��k�S�"�@~;�U>a�b$vn���\,��kKm�DVf!Hf���4(`���hx����� _��Վ��!�SJqGu0�L�\pF4@@!��t^�-�<�$��c����^���H��+Hx��Lm���E�����ӗ/�dڥ���V�Z�t�jTc��c���������.��"�D�� D�k�o%���V���e[m4m,�&����ɧ�onSDp��%�n�ߧ-����1&��������
���8}���>6j ��([?ؖ!-�)�L���%z���ҙ� \��B�WÂ~#w�4�5mF�3�L������s[_�&�����c�A�z�-כ#�֝���Y٬��K���)>�����+�'�q��w��c|l��
����1wy
ڗ�� <��.�<��D���� ��2������w���������Ϗ?�p�SDQ�o�^��8�W뢲�G�ո 
1�D�Q1^��E��H<�Wc����l�Ƿ̟�e&	oH������h�s��f�;�/������M�I�e���7�q����6J�������7�D�����aY�wԥcm����}������&��0�_���x5���x���f���)"m���8?z����s��w���ީ����an���>q�����Ա`�n���E���*�gc�@��j�-���P�S�,�c�A���_,ν�����G��}�z#K��Q�=��U�CjY�!$& ��3�< ��t6)�e��N�e���E2))Ɇ��&�F�(�C�8��_%2}�ML5�V�%��}�,{u����\�����H|EN4s���ܥ|%��1&UN���jFkWïx"_�/�����S�8OMd��J;�
�թ�}�)Ko\�,g���+�9{�lV�$��R�*p�{)	�8��,����T��^S���J/�r�,wX�
'$킦q��w��E��+X�d�4u\(d����ʕ\��#�K&r�!m����ҎtN��I.Qp[~�˿�+B���g�ӓ�|���^��\��R�wR8)��$"��s���2i[�\j�|�ZN��L�2���L)'ƥ��I&��=yO�R"�l�_&
|�uY*玍�n,�F=�?����b�ubO?h�Ǵb�~
���4��T5�����:��v��Z��Q1z&��L��Q.'r���s[K��D�W c��HI9��{�\B�o�҅$�iU-�+�r�})�h�gЉ%���;�,�z���6��,<<4�d:�S�ב=<˝�d[�G0)q)'W��BR���wzRn|��O���⑓x���=���T�O*��x7Y5��Rd?j���5#m�(g{�x�)������ ���b<֭�+Ei��N���OM���:
�~>0�Ɓ��h���t����{}dL�x>����������o�=oQ��>q�_v���?w�װ��_`��'��<���[��$/t�˧4�1��f��,�ۣ��U(48.�;8H�j(������١t̕�7(�9Ѵ��N!媸_���U��$�n�*T��N�ҺJ�d��ձ�Nj��*j<f��V�_(F����"��=!�6���bN�P@T�P���R{e�Q"�4r���p�ٰ���_,k��ڽ���ϋ�������;�Y�Lb����e�$fY�Y�Db����e$fY��Y�<b����e�#f�m��4�~�1}w�/��o�����
�l��S��M_ã/�������Y	���J� ����VO��yz]R*u��TPR��$�Xϔө
,�_�.ON����F�Ï�0}�εd�8ų7�q�o�dw����֕��m]:���ڻ��{�Q�����p��}�^���'ȿ�VL����:�����Hx����' it�&���&r�/����"I�@�yQ2OH��Q�M���ٛ�{�WW��F���0b�� Sc��C�a�  R���*��5�$�wt-��䪤�
t�F��O�|�����_℞W���<��Q ��6T�������]7�Ȗ:H��XB�^�"��H3z4�,5����������`ϰl�½�s�y��[�b�� Sx��C����������������F���K��ݤOI鰪�O�K�����}S�D����o8�G�ݨ�Ϋ  9��MU�#��NS&����>h��4�<:��� �h��O*$��/�T��i�x��I����Q��V��<y{2!q <-���͋g�ܤ�O���"(/�u���2�A�$��g�YbI����"g��;vIj�oM����-m�3m���o�\6�R�3��r��r���W��Bڅ�@Z�\7ܐ�WX�eB�q��7���]�O�t��Dg�]vdċ��Eċ�̱�U1� �Ǹ-H@��l�{�n{0�&�y����� 7T6W��c�h��̰?ugG�|�1bW>����C��?��\L~�x�J ^l]k��ñ�c;�]�Ơ>����K A�������!�\5���C�v{���	���;)ƒ܇)���p��q��N���pn�џ\+������:W�nā��l������xw��v������@(D#��e%��$���]��7W��#h��E*1Ls?���^�y_�wK��ə�����ѮcΠ�[����u�Z�%!�.��k7�G�+����~�����r]W �dOg=ׁ&���9���	VLH�o�n�\f�����Tz�̂Ty��<�*)�����t7��h�T�l�w�/��ƽ��!P	�1�z=���3C��E�s�G��v�y+�ԍ���L	k��ܭ���>~�
h�?�9<4�;rjY8��]���@��P$[I��wy
�1PLa�����wwk��YD���������� �W�q���J�c���M����\b�>/|���e�������O�*�7<��F�o��������O�%��E|�"�į������_��!�+�:�]L��'�N�♸��Hĕt*�R�X<���8�US�TL��d����j2�P4��L�V��K��#�#�~������?���g����t�T?O����L"�#���V,�o��oQX��~;�ݷw]����[���]������=�+b���{�/�E���Ӟ}s��^�4t�1x��#��Ε�� �i�F)[T��Y�a9�մ���Z��9�]��c�g���1:;�l�-<�ό��Ț���B�:4?#vgdԼ[TV-�u�Y=)�uL[�i� ���"�bJ��zGb�cIl��vM��	�i/&�Qv)�����8y�+�%�.$�Ƹ4�G�I�������;8��`a�{���8�iS�\h�:t��S�p����N3�;�6��a��R���ց�:*-ّR>D�Q��&mG:�L�#jeWB�����L�Z��Ń�LV�|eޤΝ�Zh�R0cr *}1s8��F��ԋQ��s�F"��G�%8>"�)l�`���%7s�a������3�z���V �q��x�H��Lb����薒��L��u��\�;�a09Ol_p��Zn9=��3�� ^mb���Ձ^n���$����Y�gZN(��V2��f�n0�q��O�T]���0Q%����̱Ռ^qv����R���F%���Jد�6�y}&S���P�;����'�Ȳg+*U�tcF#7^^;�E�1p!���bE ��eD��b�֢�@��v�'�a�=�����?�/N�U-5��ti_�t��KU⶞V�li��m�"+�E�'%F?'bz[H%�-��6C��N�mN���������ӈ�t�d�9&��"��+��I���D�
���C�Ҋ�r���s��)3�y"[���ϦTj�HjI�j�-�ɏ;m-�/�q����Ü����̜3*�!���ѱ�ju[�i�F(�>��~?7�gR#�
*.�F����G~a���;���k��+{/�������@l}���%�{�7+��6��/���S�i�e���{_���m��N����k���^��b��Hd����+���\V,������މ��׉�!W�G_��'���G�"߿��{�{���ײ��
�2�e�`g�U����^V�t�$��{d>�����sLӗ�9z��{N�e,�$�c�E�Fk���9q�9̹�u�^�X�cos��m����oXC!��Җ��z��ص�Y�A����n7�uvE��Y*�*p���?��T-ў)�U��b��)�X��z)&7�՞5)8���`�L��:�K�.LJ�&�q����\&�e<ˠ�s$N��j}g8��X�A̴sN��l�2��,�t��/��i�sȁK��o��6#t�+���Z��p,��~�.����LI��htL�$�$��T��Œr�n��-�G@%D�1�Yu�OE�X$��;���Y)�	�ьN�Bz0�J���k�&�e9P��RTZ��8+��L�ji�AcuA�O���o�����򶂜_1Ǿ�̍*_>U��N��"�YV��e�.+�	�7�Ҝ�3��;q[z�ɝ�:������Pn�z�f"�/!W���L�-����s�r��,iV9�r��V�уa[��&j{�r	�m�U��4F�,W�u�ƌ3z�l�V�T�s^����C����8��̻�rNd��%�36Ww��ڣ��4�z-!h��b���A�=8?�k:��4�:��\�$^�M�Q�fG��LM-t��R�=�Zʄ/5������3�]�/.	��I�L�X�sE]��L�7^:6���a)F�h)WO��Ҫ��t⿼�&*$˵ +�Q}2>��3�ʲee ���đ��+HL��x�d���G����Xp�0!n��b�_)L \��¤��y_��5���Y����Qnr`��f�'j�#�=�S�N�����tfޭ7��W҄�mv*�$k��J�h���A!n�2��NdV�)�(�(�/Qv�t�ܑ��l�|�r�J5��S�J�h��<8S�E��C����
K�z3�RZ���ˋ�T��LWbNN��3	�N���<�+LVoE�4���dGdS���u�(�0�R��kg�UΨ�WS����z�G�oB�~H/�j䍰�����e�k��ƅ���{�.�P-{���b�=?��_&~��ckfIˉy3��ef�e��ؽAS_���"��o>y�z��2��M��Gr�E�y�x�^{������0���+��/��ބ��J��ěE`����	FH�'<�������W���8gS<t{�����MorE����Z�d�>�g�>J�/]��XFe�x�����2�-���=�����/~�9������$�ċ���܍�/�F�=��O���i�����}�ްt�Z�CVIG�S�̌��a��Y�)��	���jcw����vME&x���}���zd�g؄)�����?�'}��uz���C���ZUX6BWl�%�8~���	ކ�Y7�\<l���Z=C� �+bw4�pG�A���Cz{���+�n�&A���p\
[��E�!d��a�a`��c,d��Z"�"��TŅz��E�Y����7�T�f�.��]�70&��H�p�#lㅳx�NHR�Ik`���Pf�N!�.���_���%�l�`�/H�kk5l[e��!K85�� ��H��E-O�7�p�p�������lc�[W�>԰Q�\5�	6V�s}j����̆�>j\��!օ"5b�hC&~`������ �ON�����5��?'�x]�+XA%� sA���t̠�h:[�r��
,�N�#�A�qX/z�D�L 醵�>��`�By���zR5�'r:��D�c⚁�A�=�u�qǙƽ�9E��8�{�W��������Ż�~�A�i~	_ ����}�k��>�afc��C��,:=�Tl=���{�kX���M�g�Fb�7?1$X��C]��\�C܋���-�S3�%%�Iw��IB���t������EP�M �P?[�-fN1��Üֻ�5UlٺV��Fڸ�R����	
/�D����@d��"*��le��Pρn��1`I�x�K�c���!��kv�U�ր��uK�5%< /[x��Ż�������'f:0����G��H�RFe1��^�!I[���F
ҳ���4�-��l2��a��(�'x�ؐ(`A�nٰ��,��l��v�NG�+�~6�z����!�µ12����Zvi�Av��O�X��r�'���[�Y ���T얲n�a�,Ϋ��U�͐"n]k_�b�V�&��g�>���7Eal(8]6�����jĖ�Q!ф�m �h�[l=Ag���h���#D'���٩9D�6ǻ�]�yH�}�K ;D�^(+�R��C�S��qc���M����4E���?�0��kN���F~Mt�m�.�T���#��L��[��[芃�3�U�1�C�olj�Ϝ9n���{>� ����"����]Mv��7�������C�][�5���iz;�s2�����{�2������ 
�=W+�s��8�����̡���u�aB�4ǜ��H���݋���䎂M�q�7з
A�h,��U���Y^(ߠ�����`�WVt�w��@�
�Ǔ)�@N���
�q5��R�^O�SJ�O@�q�?K+r_�gS �Ȩ�N�{����(f�y�ܠV:@�\?�n���`
v��]�i/vLH0`.̡�|:�Tȩ$�e9����
P(ZM�b  H�Y5ˤ2j�

!�p$3Y5�V)�*���;ğ�|����Po���z���{ zx��xS���<u����b�q׺`g���X���ȶ�����_�L��\-��c��HQ�vy6�)���|��(���إ��ߦ�y�X���k��&/���kWt*ǔ�fM���Ǯˍ"^h
��0�WA ���+�S��D͉�L�������ۃ��q��\m��b��%��n܁�.j_DS�6�=嶝&0�� \�u{�`��7Hv���)��<*t3|�U<B�P)��x�����}���\�[�ti���Va3�x�W�ZU�H�fc}q�F�=��L����ӭZa��%Q�#��=
������[K�m㪹#X�XmJ�j%/N+�Ԯ6�DػG>��/�nV�A:���L0Յ^c��E�A�e=	<W�e�
-�?9FbX��?ʙ�ހc�ȟ��rE���������+�a2�I<S��r�<�Fߙ|���^B���$�x�8��eD ��&N}y�����{���ȶ������b?&��
~��+�D+���`p�V[��C	Č|��-��|W��6�ٚq�k$���8���(�*���Bё���NQ��n������,Z�=]��D2F����<�/9�itGO=������������_�ѷ��8�J������D��NR��^��~��ӿmX��ޙ,'�mkx���s"
���Du��jrBB� �@O�NWV���Lo�J�oP� (;A��_���  �����4�?p��"_�?'���(@��O��vI���ӂJ����/�u������	��6���_������������	��_I�5
�ŤH�1����Rd�.�#?��
c^$�2��+��K������t~np��������������$����Ŭ6I7y�ٮ��ckO�F�پ޲��2������Y�;�N��r�sܨ[�=?��A�fzkz�6C&�;��#���g��a���3�O�_N��R5n{�8$��a�j�#�����O7�|W_i�>���uw�xp��C��:>^��{C�~��cP\����)
��(�A�i�A���G*��Fo`�/����_�����������O���Ԯ�-�Ԁ���W���p������i��Y"����W����<�?
����=���.Qt�����di�^�y��� �ꄣ:��u�O�����B�0���e@����������##����
�!����O
��"��߹������O�t�8�嫶Ԋ�l1,���ϲ����R�/���'�3�����e�{��6�I�o��(��'�j�~~�����'�th��*��\f5�4�eu��z������t��T��sc��V�*��F�����2 �e�a�\j_��f�_������>_�>���l��j/dzҢs�8���~Mxm��oY�����3�,g�ݞ��ܧz9,��"W���X9q��W��ΐ?Ԓ�fQ�MK�sLT�9Y�C��Ocw����F�O��t���`�x���G�[�ݒX�?��W��i@R � ����X�?��+/��-Q��"������ ��`����O�������,M���* ������l�]�9�`�������C�����f����_������i.�x�4�U����o\�od�����	�o<�X��z��~��>���񬯮�d�ξ�6\����8 ;L�7��T��V�C1��RKI7�֘��ݩrvd�67}޶-={
뉿���l��S\�?���,�sH�PT�0������K�{�����c.�lJ�J�0I��%Oobmo��5��(v�i�MҕS�;83|q�HuVQF�����4���"CR/'mG�hmO��@��,����Q��P���[Ɨ,�b�+ �����p���g�i�������G���GE!�S'r+r$'IAL�l B�a����!�!Ʉ|�1�1	g�88��������W���ʎg.Ω���u�'�m&��tޭe�Ɯ�֢aM�I�T���wD1r7'�??��8�<I7�uw��]���;�a99��S����F���%Y���6����%�F���pI3?n�gÏZ���{����?�������o��p����:����������q�~3>!8�?���+㿣�胣��N�q"$.q��3^�I�p�9��f�y��s�l{|����w������ۗ�oK;�����>'f����z�Xr���$c��V���eU(�ٱ6p��/��7vt�4�� �8���<��4�+����~���� �_0�U0��_0��_���Wm�<``�������?�����������^��MU���z"t����yz��?ZT���������M?#�nk�3g O�� �_���3 �V5l�V�B~�T��! o� ;�ٖ�M�^��[�,�zI.�Ì��u�lF��Y���o�eH��?��D֣���m?�깐��{s��7�E��x�7N���۞��׫�� p����k<pP��\�'!/����.�˭z��b�y)Z Re~h�J�&C�I�q�����R��	Ǚ[JMml��71�Ǘ�V	e�����B����G&i��F]���2Tjө�R�t:ӌΆ���~��E�#��"�걻�.*�˫|��Z�8�[c�HΊM�Ǘ�m�g2ރ8�?�}��X�(����C�����o�����N ��8������`�	H�v�a*������@C������a�?���v������Q��Ɋ��E�lH����<�J�@��3~�N����D)f���y?������A��S��������^78.Kc7��7�	.��HVϚ]�s{?bK޶ح��_�ݾLv�޻�n�.���hz�q�O��Ol֌�ݥ��0钴>w���eē�])�>��ǖ5�Rg|P%�k]�Y7���{���O�����>^�o+�~���@q�ߑ��i��(�B����?��!����:��8��_����]����\��ۏ��r0&������P��C����o��P���m���]�Du�y�N�t�/W�]�wXV�����K��N�s�gz�o�?��}+e���]cg���1'?�T+�f�w�(�gš�˳;�F��I�'��/����ĸ?h+�Mg9	��p6�M�l�����%x��+4�v#��^��X��L
s1(Kf�ĭ��=�z�]�V�}G;��>x�QPE"�β0���ڍC��v��୔ns-����]ىl�C�pT63�P�d�1+��č��|����bw3#�F��H\��k�}������u��$�������dzQYI8E��/cݖ������������������8�?M1���"��?4������o���H��o����o����?�����*� �@��������@��O?B ��������Q �a�/������������P����cv��U�N�1(��{��$��4I����?
P����-T�?����WE���!*���r�����G��!*���r�����H�K�a9jP����`a�`���������G�����?����?���B�����D`��0R8����?0��	���?���� ���?XQ!�n����C��2��X�,�������� �`���6���`�#0�Y�@�U@��������������H�J���98����_���������
,����Q��P���[Ɨ,�b�+ �����p���g�@N�OQW3���32D�g��B6C����*��dȰd�S��K%���,'�/��O�����������7F���L}��7[׈S��Ti���8NB�F��(�6�K�2�	�+�H���vs�Z�V-˾�l��/۪,�'5s�vg�e�W�Z9b��j[�`G����s�����E7�D��7���8��1�r]/�5 �u�X�~��^T�o8f�p�����Q��?_AշRp��C�WX�?��T���w����U��������_/d,�\˻��Qۘ;"�uf��Z���߼���w�/�N��_�A��ݣ���:ۭ��anD��9�ɜ$���7��L�ƾ>����o����ܔ���������ɘ�Q�o�����}/x������/"0������w|o�����_��_0��_0������V���e��������O����?��1�X=�w�d���$N����F���߳��Y;M��I��cH|ώ?f���AX�i����Y�5�	٢X"҂�85ZY�]�D5;ɘ'�;6�~b.��\����1�m_�N��ؒ�w��Y�mA�{�q�坾��{�t���6��R�����������E�9,Х}�UO�^l7O#ED���X)׉!��=�2n7�١�����;����p/i��BS�d0��_?����s�f��(՚��gʩb�'Cm���5�(Y��Z$��6ٵ&\->�e}��q�����;+���=D���-������/)PP�E�G\��|���g(�?p��(���O��F�G��6�A�����?��,IѠ�(�A�i�������(@���{=a�~�����!����WM��
����U������}Z;��$�%)�h�3�]��_���������~],��猛v�U/����s?�f��#�{��Kʏ���s
=�R�-�שK�R���e����e.o[K���-䁒�_2���5�j)Jqk�s���BS��2~��t�Ǚ��Z�z�\�t5�gcZ<y�k$�^�;�_ɒ;�뜒w(�_��ѼɬJ�xJ	����XLr��D+>��o������^�BI���gY�{/i?��Ƀ�CN�n�O��HK�TQaؙ�LMq����c��m
'i��-��-b�jb�Vk�*˜�-YSt9U�y'uE�J�6��#�E�����D:��Ӛ`W4S[�����R��)y��Aa)�9wJ�����</KnW[u��7���������/"��?!�Ȁ�?f"�Ҿ4cBʿ>��4#��͟��B�e���r!��dHE0��Q�����_���C¯����d&���h��`���E��(����1n������{J����ޮ�խ�+7�����G�o��w�8R��
p�����?��!��2����������8�Hx+��)o�?�k����Sw��JO_l]�O�h������_X4�4������%؈������?���������M,e������^�~����&�ݖ��T�%y�o״]/n,B�{��dFҚ��k���Z�&{^j�C^V�Af�f��=V��ٸ���$5v��-�G�7����#���@/ש"דTΚ5uT��on����/ڴ�n�c٘.K�$���t_���o�Z��Զ�w~����u���<�]}�
|�]]���| �z�����6{'����l��9��@���5�Zs�5�4|`����	C.'�8D�0JC��z9�t�����Wt�&�ڜk���(��nc,/��檏�G�������y�ĭ���M)���J�n��2���2A$3~:���05�Rq����x��y����x^��`���������G�o�o��9�'��'�FS��ڡ3@aj����|��u��h^�9O�_�-�jA~T����k���b���Q��4����k����Ki<�jR�+<�����Y�?�e����l�A�AZ����?�U�����o�������i���TAey��6w��Pn�kg�������0lr�����序�]�}��[��D�4Ađ��@(5��ck![�屵������m�h!4.3WȏN]]f��ǥ+�����P\j�ծ+���y��pRJ��<���	����4:�T
��hV��n�h5��r�t��1>��*�p��΢�zV�)Z�v��~�Dg-��O��VSnXxl����?
���&�F��ς㻑�a���Ф6V�CʖX;쭕�+2c{[�x��[�����%�ye�ՏO���6�Twu}R��ld(��r0�{��g�
L9Z��YS�z��Vu@���d.��#k��1
�~�Ɨ
�cĀ�R��r����4���[�C�O*H���U��
���[���a���&�C"h�����:��)A�w*��O����O�����o��?ր�@.��}�<�?��g�����r�\��W�oq���� ����������A��E�^�+�|i|������� ��\����gJH������G�	���������0��
���d\0�{ ��g��~���?��,�|!��?���O�X��O9����i����?���� �������؍�_��HY�?(
��߷������ �#%���"$;�"��� 1�H�� ��� �0��/m������������9�������������S�?���?��C���7�`�'d��ǂ�����}�\�?y���RA>����B.�����������ȅ��h���Y꿥qo@�� ��o���/�W�?���r��:MกiefN�z�$z��� uS���2eL��u��MS����4�
Ɣh��>o�����/���?������'�ⰨP���_����6����R�IV��K<��:j��Ej26��Z4}Z��[ª�q�O_l�*���SQ���ս��v��{l2]=h�f�EGe:,En;,��Rm-�o�ۣtOU���Қ�n����]N�����m=�*��Q���%V��9޻���<g�C����!��?\��o����������%��?�!�n��E����3�?N����{b�N8��z1��?�Z����yf���5�_⿺0Z���`��t�ö�z�Ok
GwHL�h�*���vǴj%����\Q9�ZCi9�.���Ή��[h��S��C��Z��/��oFȲ������/�\�A�Wf��/����/�����������}��J����7���_�Y��[V�^`mԞY9����������K�r"7�pO[r_�@n��`�r���d�knz�.�aT�?�;��ߌUm4ok�Ȕ9�0.N�h\�2fΑSq�UbI�&�NS{Ķ�R�^I���j9��%�Z��6Y������W)"�*;�r��p��,�������2�h�q�a-�ޫ����(}>r~sSP��c�R�|��'ǚOd���ө�l}ǻ�.6�f�P�vŷ��z]��Q����r(��,��� �|6�/�����!��G�&�4�u	S۵���Z���{�<�?�����������S���k����(1��?��=r��̍�/�?���O/^z�A��=����������������@����e� w������Q��?� s��x�mq� ��Ϝ������
�����>�����������4 ��������\�?���/�T���� 3�����r����Cf���� �?}]��A�G*�f��)��P��?䰼o��p�cK`zzn�W�� ��=�O��X��V ?V��|��H>�3�I����I�^jۗ������n�	��.w����yZ)V��!.�H���}}^Y����i�謱�̩�:��k��O��Ìd��9>M֢b9�����_�G�~/e�ȍ�_UNk�cQ�a��T�GE�	Ui�ee�p�N�����tyb����_֙�eg"i����#�\N�<��0JC��z9�t�����Wt�&�ڜk���(��nc,/��檏�G����3`�����!s��b�����}�\�?��g�<���KH���o�a0��
�����������I������E��n�������r����r��7����F.����ߊ���$������o�5;d�+�GJ�4'�_j�_�~��I�ex���׽��/e
T�<��S@yl������v�,WU�����z^�ߔ�i�X/4��7�����W��4�����F	]<�Jt���}}Q��ƈ�z ��� $)���^�F=V���UѮ��ev_sېhWA�[fE[*{���*Z��9*��[R��Bw(v�ʝ���Q@M5s�w[�f��|��ȅ��o���_� s��i�[�>��}�<�	���X�O���B2�ZbL�Vu�RV�y	���4��p�0	+W
�MLe0ӤtCch�Rf�9M����+#�k�O��O?s��3c�閵�t�1'd$a��R�Ũ�&�^[1��1+������q3!���*ꞯ
~d�����j�HKJ�l�*�jk��+�����i�QB� 	����΢�`�>K��-����|-�����gvȴ�O�ʺ�y��!�����������"�q�uS�%����e���y��jl/D�#):ǐ*�$��k��V#[Dw�z\���%������[��*Yo�\r��ި�)��}aDM�҈�j� �[�iWj��b�mI�I��{hg�	��:Z������E>����/*������y���� p��E��e����/����/�����h�l��GQ%��[�o��?��[�豻�(Q��p��ܫ��{������j ��B /k �K+ة+����-��3
Z��j�j���Q����,ђ�����H���?�ץ�R���6�(Z/ϊ�m�[-xny�\�!���T6�u�t�x�r=�r\wXc�dL0���P�&�e� r�`��y"�~�ֽrYrá������67�0��4%��!���=���b#��r6QV�C}.��r�Ӿų^D�0�<�4a�nzJ�hy��3#����V�!{\Y�c���H���F!yJ,�6lz���B}D(�V�ͬ�|8%{xiZ��r�����D�F�9��Cxx]�����X�}��I���4p��-�-�_�������;�������m�� �\O�?����j��������oLge��_N�,��c'(|��Bor���,<|�}}����d����U�5V�S�_������I����[�������-�|@��}���$�<��}�7��p�x��{�NL���������㢚��pp���-�����7�?��aA]��'f����	���������ǻ���I^�|a{|���\u���_ə%_�
�m��������HU�����?
�����x|�����~�c�=����b������+���/�ǯ�"�Oz��]�Ǆ�<�秺��L����wϽ���<׫�m��N��
�ɍFj܄��/Ԏ�ᯌ�e���S7��)>�qu5>��<�rP������:�UX�L�j�� ��Ϲ�?`{���)�����{���'���f�����)����cG��ax_�_ݙK���;��9�C/x��c��_��/���)>l
7B��b0
���KN�5B���t��<�Xe�_����_���gw�!�����#���~�o�DYz�Ϯ."�U�	?��)��޽�a��~о���/kB               �R�f�s� � 