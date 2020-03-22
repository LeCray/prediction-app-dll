#include <torch/script.h> // One-stop header.

#include <iostream>
#include <memory>

extern "C" __declspec(dllexport) int __stdcall prediction(double& a, double& b, double& c, double& d ) {
/*
    //yoo
    if (argc != 5) {
        std::cerr << "usage: prediction-app <inputs>\n";
        return argc;
    }

    torch::jit::script::Module module;

    try {
        // Deserialize the ScriptModule from a file using torch::jit::load().
        module = torch::jit::load("C:/Users/Thembi/Desktop/Trading/example-app/traced_pytorch_model.pt");
    }
    catch (const c10::Error& e) {
        std::cerr << "error loading the model\n";
        return -1;
    }

    //std::cout << "argv[0]: " << atof(argv[1]) << '\n';

    double array[] = {a, b, c, d}; //atof() converts const char * to double.
    //std::cout << array[0] << '\n';

    torch::Tensor tharray = torch::from_blob(array, {1, 4});
    //std::cout << tharray << '\n';
    //std::cout << torch::ones({1, 4});

    // Create a vector of inputs.
    std::vector<torch::jit::IValue> inputs;
    inputs.push_back(tharray);
    //inputs.push_back(torch::ones({1, 4}));
    //std::cout << "ok\n";
    // Execute the model and turn its output into a tensor.
    at::Tensor output = module.forward(inputs).toTensor();
    */
    //std::cout << output.slice(/*dim=*/1, /*start=*/0, /*end=*/5) << '\n';

/*
    double output_1 = output[0][0].item<double>();
    double output_2 = output[0][1].item<double>();

    //std::cout << typeid(a).name() << '\n';

    if (output_1 > output_2) {
        return 0; // DON'T BUY
        //std::cout << output_1 << '\n';
    } else {
        return 1; //BUY
    }
*/

    return (a + b + c + d);
}
