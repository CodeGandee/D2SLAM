all: jetson_base jetson_orin pc

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build              - build all images"
	# @echo "   1. make pull             - pull all images"
	@echo "   1. make clean              - remove all images"
	@echo ""
	@echo "-- JetPack 6.2 (Recommended)"
	@echo ""
	@echo "   For JetPack 6.2, use the organized jetpack62/ subdirectory:"
	@echo "     cd jetpack62 && ./quickstart.sh       # Quick setup"
	@echo "     cd jetpack62 && ./manage.sh help      # Full management"
	@echo ""

amd64:
	@docker build  -t hkustswarm/d2slam:x86 -f ./Dockerfile.x86 ..

amd64_no_cuda:
	@docker build  -t hkustswarm/d2slam:x86_no_cuda -f ./Dockerfile.x86_no_cuda ..

jetson_orin:
	@docker build  -t hkustswarm/d2slam:jetson_orin -f ./Dockerfile.jetson ..

jetson_base:
	@docker build  -t hkustswarm/d2slam:jetson_base_35.1.0 -f ./Dockerfile.jetson_base_35.1.0 --build-arg USE_PROC=20 ..

jetson_orin_base:
	@docker build  -t hkustswarm/d2slam:jetson_orin_base_35.3.1 -f ./Dockerfile.jetson_orin_base_35.3.1 --build-arg USE_PROC=20 ..

jetson_orin_base_62:
	@echo "Building JetPack 6.2 base image using new jetpack62 subdirectory..."
	@docker build  -t hkustswarm/d2slam:jetson_orin_base_ubuntu20_jp62 -f ./jetpack62/Dockerfile.jetson_orin_base_36.4.0 --build-arg USE_PROC=20 ..

jetson_orin_jetpack62:
	@echo "Use the new jetpack62 subdirectory for better build management:"
	@echo "  cd jetpack62 && ./quickstart.sh"
	@echo "  cd jetpack62 && ./manage.sh build d2slam-minimal"

arm64_base:
	@docker build  -t hkustswarm/d2slam:arm64_base_ros1_noetic -f ./Dockerfile.arm64_base_ros1_noetic ..

arm64:
	@docker build  -t hkustswarm/d2slam:arm64_ros1_noetic -f ./Dockerfile.arm64_ros1_noetic ..

clean:
	@docker rmi -f d2slam:amd64
	@docker rmi -f d2slam:jetson
	@docker rmi -f d2slam:jetson_base_35.1.0
	@docker rmi -f d2slam:jetson_orin_base_35.3.1
	@docker rmi -f d2slam:arm64_base_ros1_noetic
	@docker rmi -f d2slam:arm64_ros1_noetic
	@echo "For JetPack 6.2 images, use: cd jetpack62 && ./manage.sh clean"

upload_all: amd64 jetson_base jetson
	@docker tag d2slam:amd64 $(name)/d2slam:amd64
	@docker tag d2slam:jetson $(name)/d2slam:jetson
	@docker tag d2slam:jetson_base_35.1.0 $(name)/d2slam:jetson_base_35.1.0
	@docker push $(name)/d2slam:amd64
	@docker push $(name)/d2slam:jetson
	@docker push $(name)/d2slam:jetson_base_35.1.0
	@docker push $(name)/d2slam:jetson_orin_base_35.3.1
	@docker push $(name)/d2slam:arm64_base_ros1_noetic
	@docker push $(name)/d2slam:arm64_ros1_noetic

upload_base: jetson_base
	@docker tag d2slam:jetson_base_35.1.0 $(name)/d2slam:jetson_base_35.1.0
	@docker push $(name)/d2slam:jetson_base_35.1.0
	@docker tag d2slam:jetson_orin_base_35.3.1 $(name)/d2slam:jetson_orin_base_35.3.1
	@docker push $(name)/d2slam:jetson_orin_base_35.3.1
	@docker tag d2slam:arm64_base_ros1_noetic $(name)/d2slam:arm64_base_ros1_noetic
	@docker push $(name)/d2slam:arm64_base_ros1_noetic